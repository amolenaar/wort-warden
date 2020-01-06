local accel = require('accel')
local gy521 = require('gy521')

gy521.init()

while true do   --read and print accelero, gyro and temperature value

    local ax, ay, az, temp = gy521.read_accel_temp()

    print(string.format("Ax:%.3g Ay:%.3g Az:%.3g T:%.2g - Pitch: %.2g Roll:%.2g Tilt:%.2g",
                        ax, ay, az, temp,
                        accel.pitch(ay, az),
                        accel.roll(ax, az),
                        accel.tilt(ax, ay, ax)))
    tmr.delay(500000)   -- 500ms timer delay
end
