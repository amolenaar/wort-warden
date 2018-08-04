local id  = 0 -- always 0
local scl = 4
local sda = 3
local MPU6050SlaveAddress = 0x68

-- local AccelScaleFactor = 16384;   -- sensitivity scale factor respective to full scale setting provided in datasheet
-- AccelScaleFactor = AccelScaleFactor/10;
-- local GyroScaleFactor = 131;


local MPU6050_REGISTER_SMPLRT_DIV   =  0x19
local MPU6050_REGISTER_USER_CTRL    =  0x6A
local MPU6050_REGISTER_PWR_MGMT_1   =  0x6B
local MPU6050_REGISTER_PWR_MGMT_2   =  0x6C
local MPU6050_REGISTER_CONFIG       =  0x1A
local MPU6050_REGISTER_GYRO_CONFIG  =  0x1B
local MPU6050_REGISTER_ACCEL_CONFIG =  0x1C
local MPU6050_REGISTER_FIFO_EN      =  0x23
local MPU6050_REGISTER_INT_ENABLE   =  0x38
-- local MPU6050_REGISTER_ACCEL_XOUT_H =  0x3B
local MPU6050_REGISTER_SIGNAL_PATH_RESET  = 0x68

local function I2C_Write(deviceAddress, regAddress, data)
    i2c.start(id)       -- send start condition
    if (i2c.address(id, deviceAddress, i2c.TRANSMITTER))-- set slave address and transmit direction
    then
        i2c.write(id, regAddress)  -- write address to slave
        i2c.write(id, data)  -- write data to slave
        i2c.stop(id)    -- send stop condition
    else
        print("I2C_Write fails")
    end
end

local function I2C_Read(deviceAddress, regAddress, SizeOfDataToRead)
    local response = 0;
    i2c.start(id)       -- send start condition
    if (i2c.address(id, deviceAddress, i2c.TRANSMITTER)) -- set slave address and transmit direction
    then
        i2c.write(id, regAddress)  -- write address to slave
        -- i2c.stop(id)    -- send stop condition
        i2c.start(id)   -- send start condition
        i2c.address(id, deviceAddress, i2c.RECEIVER)-- set slave address and receive direction
        response = i2c.read(id, SizeOfDataToRead)   -- read defined length response from slave
        i2c.stop(id)    -- send stop condition
        return response
    else
        print("I2C_Read fails")
    end
    return response
end

local i2c_read = I2C_Read

local function MPU6050_Init() --configure MPU6050
    I2C_Write(MPU6050SlaveAddress, MPU6050_REGISTER_SMPLRT_DIV, 0x07)
    I2C_Write(MPU6050SlaveAddress, MPU6050_REGISTER_PWR_MGMT_1, 0x01)
    I2C_Write(MPU6050SlaveAddress, MPU6050_REGISTER_PWR_MGMT_2, 0x00)
    I2C_Write(MPU6050SlaveAddress, MPU6050_REGISTER_CONFIG, 0x00)
    I2C_Write(MPU6050SlaveAddress, MPU6050_REGISTER_GYRO_CONFIG, 0x00)-- set +/-500 degree/second full scale
    I2C_Write(MPU6050SlaveAddress, MPU6050_REGISTER_ACCEL_CONFIG, 0x00)-- set +/- 2g full scale
    I2C_Write(MPU6050SlaveAddress, MPU6050_REGISTER_FIFO_EN, 0x00)
    I2C_Write(MPU6050SlaveAddress, MPU6050_REGISTER_INT_ENABLE, 0x01)
    I2C_Write(MPU6050SlaveAddress, MPU6050_REGISTER_SIGNAL_PATH_RESET, 0x00)
    I2C_Write(MPU6050SlaveAddress, MPU6050_REGISTER_USER_CTRL, 0x00)
end

i2c.setup(id, sda, scl, i2c.SLOW)   -- initialize i2c
tmr.delay(150000)
MPU6050_Init()

local function to_signed_16bit(num)
  -- convert unsigned 16-bit to signed 16-bit
  if num > 32768 then
      num = num - 65536
  end
  return num
end

local function read_accel_temp(dev_addr)
  local bor, lshift, byte, floor = bit.bor, bit.lshift, string.byte, math.floor
  local ACCEL_XOUT_H =  0x3B

  local data = i2c_read(dev_addr, ACCEL_XOUT_H, 8)

  local ax = to_signed_16bit(bor(lshift(byte(data, 1), 8), byte(data, 2)))
  local ay = to_signed_16bit(bor(lshift(byte(data, 3), 8), byte(data, 4)))
  local az = to_signed_16bit(bor(lshift(byte(data, 5), 8), byte(data, 6)))
  local t  = to_signed_16bit(bor(lshift(byte(data, 7), 8), byte(data, 8)))

  return floor(ax / 1638), floor(ay / 1638), floor(az / 1638), floor(t / 34 + 365)
end

local function tilt(x, y, z)
  local sqrt = math.sqrt
  local atan2 = require('atan2')

  local pitch = (atan2(y, sqrt(x * x + z * z)))
  local roll = (atan2(x, sqrt(y * y + z * z)))
  return sqrt(pitch * pitch + roll * roll)
end

while true do   --read and print accelero, gyro and temperature value
    -- local data = I2C_Read(MPU6050SlaveAddress, MPU6050_REGISTER_ACCEL_XOUT_H, 14)

    local ax, ay, az, temp = read_accel_temp(MPU6050SlaveAddress)
    local Tilt = tilt(ax, ay, ax)

    print(string.format("Ax:%6d Ay:%6d Az:%6d T:%6d - Tilt:%3d",
                        ax, ay, az, temp, Tilt))
    -- print(string.format("Ax:%.3g Ay:%.3g Az:%.3g T:%.3g Gx:%.3g Gy:%.3g Gz:%.3g  Tilt:%.3g",
    --                     AccelX, AccelY, AccelZ, Temperature, GyroX, GyroY, GyroZ, Tilt))
    tmr.delay(500000)   -- 500ms timer delay
end
