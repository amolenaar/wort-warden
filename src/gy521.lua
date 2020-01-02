-- I2C / GY-521

local function i2c_write(dev_addr, reg_addr, data)
  i2c.start(0)
  if i2c.address(0, dev_addr, i2c.TRANSMITTER) then
      i2c.write(0, reg_addr)
      i2c.write(0, data)
      i2c.stop(0)
  else
      print("I2C write fails")
  end
end

local function i2c_read(dev_addr, reg_addr, bytes_to_read)
  local response = 0;
  i2c.start(0)
  if i2c.address(0, dev_addr, i2c.TRANSMITTER) then
      i2c.write(0, reg_addr)
      i2c.stop(0)
      i2c.start(0)
      i2c.address(0, dev_addr, i2c.RECEIVER)
      response = i2c.read(0, bytes_to_read)
      i2c.stop(0)
      return response
  else
      print("I2C read fails")
  end
  return response
end

local function init_mpu6050(dev_addr)
  local USER_CTRL    =  0x6A
  local SMPLRT_DIV   =  0x19
  local PWR_MGMT_1   =  0x6B
  local PWR_MGMT_2   =  0x6C
  local CONFIG       =  0x1A
  -- local GYRO_CONFIG  =  0x1B
  local ACCEL_CONFIG =  0x1C
  local FIFO_EN      =  0x23
  local INT_ENABLE   =  0x38
  local SIGNAL_PATH_RESET  = 0x68

  i2c_write(dev_addr, SMPLRT_DIV, 0x07)
  i2c_write(dev_addr, PWR_MGMT_1, 0x01)
  i2c_write(dev_addr, PWR_MGMT_2, 0x07) -- Gyroscope in standby mode
  i2c_write(dev_addr, CONFIG, 0x00)
  -- i2c_write(dev_addr, GYRO_CONFIG, 0x00) -- set +/-500 degree/second full scale
  i2c_write(dev_addr, ACCEL_CONFIG, 0x00) -- set +/- 2g full scale
  i2c_write(dev_addr, FIFO_EN, 0x00)
  i2c_write(dev_addr, INT_ENABLE, 0x01)
  i2c_write(dev_addr, SIGNAL_PATH_RESET, 0x00)
  i2c_write(dev_addr, USER_CTRL, 0x00)
end

local function init_gy521(sda, scl, dev_addr)
  -- initialize i2c, set pin1 as sda, set pin2 as scl
  i2c.setup(0, sda, scl, i2c.SLOW)

  -- wait(150)

  init_mpu6050(dev_addr)
end

local function sleep_gy521(dev_addr)
  print("TODO: sleep GY-521 "..dev_addr)
end

local function to_signed_16bit(num)
  -- convert unsigned 16-bit to signed 16-bit
  if num > 32768 then
      num = num - 65536
  end
  return num
end

local function tilt(x, y, z)
  local sqrt = math.sqrt

  local xz = sqrt(x * x + z * z)
  if xz == 0 then
    return 90
  end
  return sqrt(y * y + xz * xz) * 90
end

local function read_accel_temp(dev_addr)
  -- local bor, lshift, byte, floor = bit.bor, bit.lshift, string.byte, math.floor
  local bor, lshift, byte = bit.bor, bit.lshift, string.byte
  local ACCEL_XOUT_H =  0x3B

  local data = i2c_read(dev_addr, ACCEL_XOUT_H, 8)

  local ax = to_signed_16bit(bor(lshift(byte(data, 1), 8), byte(data, 2)))
  local ay = to_signed_16bit(bor(lshift(byte(data, 3), 8), byte(data, 4)))
  local az = to_signed_16bit(bor(lshift(byte(data, 5), 8), byte(data, 6)))
  local t  = to_signed_16bit(bor(lshift(byte(data, 7), 8), byte(data, 8)))

  -- return floor(ax / 16), floor(ay / 16), floor(az / 16), floor(t / 340 + 36.53)

  -- only take MSB
  -- local ax = byte(data, 1)
  -- local ay = byte(data, 3)
  -- local az = byte(data, 5)
  -- local t  = to_signed_16bit(bor(lshift(byte(data, 7), 8), byte(data, 8)))

  return ax / 16384.0, ay / 16384.0, az / 16384.0, (t / 340.0 + 36.53)
end

return {
  read=i2c_read,
  write=i2c_write,
  tilt=tilt,
  init=init_gy521,
  read_accel_temp=read_accel_temp,
  sleep=sleep_gy521
}
