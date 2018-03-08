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
SERIAL_PORT = /dev/cu.wchusbserial14420

help:           ## Show this help
	@echo "make <target>, where <target> is one of:"
	@grep -h "\t##" $(MAKEFILE_LIST) | sed -e 's/:.*##/	/' | expand -t20

all: firmware		## Build all

dev: python-deps lua-deps	## Set up your development environment

lua-deps:		## Install Lua dependencies
	@for rock in $(DEV_ROCKS) ; do \
          if luarocks list --porcelain $$rock | grep -q "installed" ; then \
            echo $$rock already installed, skipping ; \
          else \
            echo $$rock not found, installing via luarocks... ; \
            luarocks install --local $$rock ; \
          fi \
        done;

python-deps: .python-env	## Install Python dependencies
	@.python-env/bin/pip install nodemcu-uploader esptool

.python-env:
	@if virtualenv --version > /dev/null ; then \
	  virtualenv .python-env ; \
	else \
	  echo "I will try to install Virtualenv globally, your password may be required" ; \
	  sudo pip install virtualenv && virtualenv .python-env ; \
	fi

##
## The application
##

lint:		## Check file validity
	$(ROCKS_PATH)/bin/luacheck lib

test:		## Run unit tests
	$(HOME)/.luarocks/bin/busted -v spec

upload: lint test .uploads/init .uploads/main	## Upload modified files to the ESP8266

.uploads:
	mkdir -p .uploads

.uploads/%:  src/%.lua .uploads
	cd src && ../.python-env/bin/nodemcu-uploader --port $(SERIAL_PORT) --baud 115200 upload --compile $$(basename $<) && touch ../$@

##
## Firmware
##

firmware: nodemcu-firmware/bin/nodemcu_integer_wort-warden.bin	## Build the firmware image

flash: nodemcu-firmware/bin/nodemcu_integer_wort-warden.bin	## Flash ESP8266 with firmware image
	.python-env/bin/esptool.py --port $(SERIAL_PORT) write_flash 0x00000 nodemcu-firmware/bin/nodemcu_integer_wort-warden.bin

nodemcu-firmware/bin/nodemcu_integer_wort-warden.bin: nodemcu-firmware nodemcu-firmware/app/include/user_modules.h
	# Options: IMAGE_NAME, INTEGER_ONLY=1, FLOAT_ONLY=1
	docker run --rm -ti -e IMAGE_NAME=wort-warden -v $(PWD)/nodemcu-firmware:/opt/nodemcu-firmware marcelstoer/nodemcu-build

nodemcu-firmware:	## Clone the firmware repository
	git clone git@github.com:nodemcu/nodemcu-firmware.git
	@sleep 1 # Ensure user_modules.h becomes newer than the checked out file
	touch user_modules.h

nodemcu-firmware/app/include/user_modules.h: user_modules.h
	cp user_modules.h nodemcu-firmware/app/include

.PHONY: help all dev lua-deps python-deps lint test upload firmware flash
