#
# This is the main Makefile for the Fermentation-Rod
# A Tilthydrometer/iSpindel clone (https://tilthydrometer.com,
# https://github.com/universam1/iSpindel).
#
# This device is based on the ESP8266, just like the iSpindel,
# but is using both and I2C based gyrometer and thermometer.
#
#

DEV_ROCKS = "busted 2.0.rc12" "luacheck 0.20.0" "luafilesystem 1.7.0-2"
ROCKS_PATH = $(shell luarocks config --rock-trees | head -1 | cut -f1 )
# MacOS: SERIAL_PORT = /dev/cu.wchusbserial*
SERIAL_PORT = /dev/ttyUSB0

help:           ## Show this help
	@echo "make <target>, where <target> is one of:"
	@echo $(MAKEFILE_LIST)
	@grep -hP "\t##" $(MAKEFILE_LIST) | sed -e 's/:.*##/	/' | expand -t20

all: firmware		## Build all

dev: env-check python-deps lua-deps	## Set up your development environment, Lua and Python should be installed

env-check:
	@which luarocks || { echo "Luarocks not found. Please install Lua before proceeding" && exit 1; }
	@which python3 || { echo "Python 3.x not found. Please install Python 3 before proceeding" && exit 1; }
	@echo "Lua and Python 3 have been found. Let's continue."

lua-deps:
	@for rock in $(DEV_ROCKS) ; do \
          if luarocks list --porcelain $$rock | grep -q "installed" ; then \
            echo $$rock already installed, skipping ; \
          else \
            echo $$rock not found, installing via luarocks... ; \
            luarocks install --local $$rock ; \
          fi \
        done;

python-deps: .python3-venv
	@.python3-venv/bin/pip3 install nodemcu-uploader esptool pyserial

.python3-venv:
	python3 -m venv .python3-venv

##
## The application
##

lint:		## Check file validity
	$(ROCKS_PATH)/bin/luacheck --codes src

test:		## Run unit tests
	$(ROCKS_PATH)/bin/busted -v spec

upload: lint test .uploads/init .uploads/main .uploads/scheduler .uploads/gy521 .uploads/atan2 .uploads/config .uploads/tilttest	## Upload modified files to the ESP8266

.uploads:
	mkdir -p .uploads

.uploads/%:  src/%.lua .uploads
	cd src && ../.python3-venv/bin/nodemcu-uploader --port $(SERIAL_PORT) --baud 115200 upload --compile $$(basename $<) && touch ../$@
	@sleep 1

##
## Firmware
##

FIRMWARE_IMAGE=nodemcu-firmware/bin/nodemcu_float_wort-warden.bin

firmware: $(FIRMWARE_IMAGE)	## Build the firmware image

flash: $(FIRMWARE_IMAGE)	## Flash ESP8266 with firmware image, make sure D3 (GPIO0) is pulled low
	.python3-venv/bin/esptool.py --port $(SERIAL_PORT) write_flash 0x00000 $(FIRMWARE_IMAGE)

$(FIRMWARE_IMAGE): nodemcu-firmware/Makefile nodemcu-firmware/app/include/user_modules.h
	docker run --rm -i -e IMAGE_NAME=wort-warden -v $(PWD)/nodemcu-firmware:/opt/nodemcu-firmware marcelstoer/nodemcu-build sh /opt/build

nodemcu-firmware: nodemcu-firmware/Makefile	## Clone the firmware repository

nodemcu-firmware/Makefile: # Refer to a file, since the directory timestamp changes all the time
	git clone git@github.com:nodemcu/nodemcu-firmware.git
	@sleep 1 # Ensure user_modules.h becomes newer than the checked out file
	touch include/user_modules.h

nodemcu-firmware/app/include/user_modules.h: include/user_modules.h
	cp include/user_modules.h nodemcu-firmware/app/include

##
## Auxilary commands
##
tty:	## Open a TTY (screen) session with the ESP8266 (`C-]` to exit)
	.python3-venv/bin/python3 -m serial.tools.miniterm $(SERIAL_PORT) 115200

list:	## List all files on the ESP8266
	.python3-venv/bin/nodemcu-uploader --port $(SERIAL_PORT) --baud 115200 file list

format:	## Format the flash storage on the ESP8266
	.python3-venv/bin/nodemcu-uploader --port $(SERIAL_PORT) --baud 115200 file format
	test -d .uploads && rm .uploads/*

reboot:	## reboot and resume normal operation
	.python3-venv/bin/nodemcu-uploader --port $(SERIAL_PORT) --baud 115200 node restart

.PHONY: help all dev lua-deps python-deps lint test upload firmware flash
