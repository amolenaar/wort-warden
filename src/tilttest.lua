

local CFG = require('config')
local gy521 = require('gy521')

gy521.init(CFG.sda, CFG.scl, CFG.mpu6050_addr)

while true do   --read and print accelero, gyro and temperature value

    local ax, ay, az, temp = gy521.read_accel_temp(CFG.mpu6050_addr)
    local tilt = gy521.tilt(ax, ay, ax)

    print(string.format("Ax:%.3g Ay:%.3g Az:%.3g T:%.2g - Tilt:%.2f",
                        ax, ay, az, temp, tilt))
    -- print(string.format("Ax:%.3g Ay:%.3g Az:%.3g T:%.3g Gx:%.3g Gy:%.3g Gz:%.3g  Tilt:%.3g",
    --                     AccelX, AccelY, AccelZ, Temperature, GyroX, GyroY, GyroZ, Tilt))
    tmr.delay(500000)   -- 500ms timer delay
end
