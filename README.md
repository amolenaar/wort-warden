# Wort Warden

Wort Warden is a little device that measures the progress of beer fermentation from within the fermentation vessel.

It's heavely inspired on the [iSpindel](), who's in turn based on the [Tilt](https://tilthydrometer.com).

Although similar, this model is simpler, since it's using both a I2C gyrometer
and an I2C thermometer. The code base is simpler than the iSpindel, since it's
based on [NodeMCU](https://nodemcu.readthedocs.io/en/master/).

I hope the installation process will be simpler as well, but that remains to be seen :).

## Shopping list

* [PETling XXL](https://www.cache-corner.de/Cachebehaelter/Small/XXL-PETling.html)
* [Wemos D1 mini](https://wemos.cc)
* Thermometer: [MCP9808](http://ww1.microchip.com/downloads/en/DeviceDoc/25095A.pdf) breakout board
* Gyroscope: GY-521 [MPU-6050](https://store.invensense.com/datasheets/invensense/MPU-6050_DataSheet_V3%204.pdf) breakout board
  ([Register map](https://www.invensense.com/wp-content/uploads/2015/02/MPU-6000-Register-Map1.pdf))
* NCR18650B Rechargeable Li-ion Battery (3.7 V)
* [TP4056](https://hackaday.io/project/9900-rian-simple-and-easy-built-robot-for-education/log/33402-charge-circuit-tp4056-with-over-discharge-protection) Lithium Battery Charger Module
* Battery holder

Backlog:

- [ ] Set up development environment
- [ ] Deploy minimal app to Wemos board
- [ ] Test WIFI, I2C, deep sleep
- [ ] Disable unused modules in `app/include/user_modules.h`
- [ ] Build everything into the PETling tube - use foamboard for starters
- [ ] Calibrate vessel
- [ ] Should the i2c device be connected to vdd or to a pin, so it can be really shut off.
