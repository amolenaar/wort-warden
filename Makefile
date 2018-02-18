#
# This is the main Makefile for the Fermentation-Rod
# A Tilthydrometer/iSpindel clone (https://tilthydrometer.com,
# https://github.com/universam1/iSpindel).
#
# This device is based on the ESP8266, just like the iSpindel,
# but is using both and I2C based gyrometer and thermometer.
#

DEV_ROCKS = "busted 2.0.rc12" "luacheck 0.20.0"

help:           ## Show this help.
	@echo "make <target>, where <target> is one of:" 
	@grep -h "\t##" $(MAKEFILE_LIST) | sed -e 's/:.*##/	/' | expand -t16

all: firmware		## Build all

dev:
	@for rock in $(DEV_ROCKS) ; do \
          if luarocks list --porcelain $$rock | grep -q "installed" ; then \
            echo $$rock already installed, skipping ; \
          else \
            echo $$rock not found, installing via luarocks... ; \
            luarocks install --local $$rock ; \
          fi \
        done;

test:
	$(HOME)/.luarocks/bin/busted spec

##
## Firmware
##

firmware: nodemcu-firmware	## Build the firmware image
	# Options: IMAGE_NAME, INTEGER_ONLY=1, FLOAT_ONLY=1
	docker run --rm -ti -v $(PWD)/nodemcu-firmware:/opt/nodemcu-firmware marcelstoer/nodemcu-build

flash: firmware		## Flash ESP8266 with formware image
	@echo "esptool.py --port <USB-port-with-ESP8266> write_flash 0x00000 <NodeMCU-firmware-directory>/bin/nodemcu_[integer|float]_<Git-branch>.bin"

nodemcu-firmware:	## Clone the firmware repository
	git clone git@github.com:nodemcu/nodemcu-firmware.git

.PHONY: help all firmware submodules
