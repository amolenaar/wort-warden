# Wort Warden

Wort Warden is a little device that measures the progress of beer fermentation from within the fermentation vessel.

It's heavely inspired on the [iSpindel](), who's in turn based on the [Tilt Hydrometer](https://tilthydrometer.com).

Although similar, this model is simpler, since it's using both a I2C gyrometer
and an I2C thermometer. The code base is simpler than the iSpindel, since it's
based on [NodeMCU](https://nodemcu.readthedocs.io/en/master/).

I hope the installation process will be simpler as well, but that remains to be seen :).


## Shopping list

* [PETling XXL](https://www.cache-corner.de/Cachebehaelter/Small/XXL-PETling.html)
* [Wemos D1 mini](https://wemos.cc)
* Gyroscope: GY-521 [MPU-6050](https://store.invensense.com/datasheets/invensense/MPU-6050_DataSheet_V3%204.pdf) breakout board
  ([Register map](https://www.invensense.com/wp-content/uploads/2015/02/MPU-6000-Register-Map1.pdf))
* NCR18650B Rechargeable Li-ion Battery (3.7 V)
* [TP4056](https://hackaday.io/project/9900-rian-simple-and-easy-built-robot-for-education/log/33402-charge-circuit-tp4056-with-over-discharge-protection) Lithium Battery Charger Module
* Battery holder

If the temperature reading from the GY-521 are not accurate enough we can always resort to a
[MCP9808](http://ww1.microchip.com/downloads/en/DeviceDoc/25095A.pdf) breakout board.

## Getting started

The first thing to know is that you should have

* A Unix machine (Linux, MacOS)
* [Lua](https://www.lua.org) 5.2 or newer
* [Python](https://www.python.org) 3 (I'm using 3.6 currently)
* Oh, and [GNU Make](https://www.gnu.org/software/make/), our build system
* [Docker](https://www.docker.com), to support the firmware build process
* (CH340 drivers)[https://wiki.wemos.cc/downloads], to communicate with the Wemos device over USB
* Optionally, [Fritzing](http://fritzing.org/), to view the schematics

Once you have that set up, you can run some tests:

    make test

This should execute the local unit tests. See you can deal with embedded software without having a device at hand.

If you have your Wemos board plugged into the computer, you can flash it with NodeMCU:

    make flash

This will download the NodeMCU sources (the master branch) and build the firmware containing only the required modules. Note that the firmware is only capable of handing integers. The firmware I'm using is the ["integer build"](https://nodemcu.readthedocs.io/en/master/en/build/#integer-build).

After the device is set up with the right firmware you should be able to connect to it:

    make tty

This should open a TTY (screen) connection to the device. If you're using Linux you may need to change the `SERIAL_PORT` in the _Makefile_.
Now you can type some Lua code in the console:

    > print('Hello world')

Terminate the session with the key combo's Ctrl-A, Ctrl-K, and confirm (`y`).

To upload the application onto the device, a  simple

    make upload

will suffice. There are some other commands available from the Makefile. You can get a summary by typing:

    make help

That should be enough to get you started.

The application itself makes heavy use of Lua's [coroutines](https://www.lua.org/pil/9.html). This makes it possible to perform multiple tasks (e.g. setting up wifi and i2c) simultaniously. Through the [scheduler](src/scheduler.lua), the coroutines can send messages to each other, kinda like [actors](https://en.wikipedia.org/wiki/Actor_model).

Backlog:

- [x] Set up development environment
- [x] Deploy minimal app to Wemos board
- [x] Test WIFI, deep sleep
- [x] Test I2C
- [x] Create a toggle to start into dev mode -> Use the reset button
- [x] Disable unused modules in `app/include/user_modules.h`
- [ ] Test without modifications with a small USB charger
- [ ] Build everything into the PETling tube - use foamboard for starters
- [ ] Calibrate vessel
- [ ] Should the i2c device be connected to vdd or to a pin, so it can be really shut off.
