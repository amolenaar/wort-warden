
require('scheduler')
local CFG = require('config')

-- Get 3-axis gyroscope readings.
-- These gyroscope measurement registers, along with the accelerometer
-- measurement registers, temperature measurement registers, and external sensor
-- data registers, are composed of two sets of registers: an internal register
-- set and a user-facing read register set.
-- The data within the gyroscope sensors' internal register set is always
-- updated at the Sample Rate. Meanwhile, the user-facing read register set
-- duplicates the internal register set's data values whenever the serial
-- interface is idle. This guarantees that a burst read of sensor registers will
-- read measurements from the same sampling instant. Note that if burst reads
-- are not used, the user is responsible for ensuring a set of single byte reads
-- correspond to a single sampling instant by checking the Data Ready interrupt.
--
-- Each 16-bit gyroscope measurement has a full scale defined in FS_SEL
-- (Register 27). For each full scale setting, the gyroscopes' sensitivity per
-- LSB in GYRO_xOUT is shown in the table below:
--
-- FS_SEL | Full Scale Range   | LSB Sensitivity
-- -------+--------------------+----------------
-- 0      | +/- 250 degrees/s  | 131 LSB/deg/s
-- 1      | +/- 500 degrees/s  | 65.5 LSB/deg/s
-- 2      | +/- 1000 degrees/s | 32.8 LSB/deg/s
-- 3      | +/- 2000 degrees/s | 16.4 LSB/deg/s

-- local sqrt = math.sqrt
-- local atan2 = require('atan2')
-- pitch = (atan2(y, sqrt(x * x + z * z)))
-- roll = (atan2(x, sqrt(y * y + z * z)))
-- Tilt = sqrt(pitch * pitch + roll * roll)

local ubidots

local function send_to_ubidots(jid, client, client_id)
  local msg = receive()

  if type(msg) == "table" then
    msg = sjson.encode(msg)
  elseif msg == "TIMEOUT!" then
    client:close()
    return
  end

  print("Send: "..msg)
  client:publish("/v1.6/devices/"..client_id, msg, 0, 0, function ()
    print('Send: <ack>')
  end)

  return send_to_ubidots(jid, client, client_id)
end

local function init_mqtt(jid)
  print('MQTT: ...')
  local now, yield = tmr.now, coroutine.yield
  local timeout_at = now() + 10000000 -- 10s
  local mqtt_client, failed
  local client_id = tostring(node.chipid())
  local m = mqtt.Client(client_id, 120, CFG.token, "")

  m:connect("things.ubidots.com", 1883, 0, 0,
    function(client)
      print('MQTT: up')
      mqtt_client = client
    end,
    function(client, reason)
      print(tostring(client).." failed with reason: "..reason)
      failed = reason
    end)

  while timeout_at > now() do
    yield()
    if failed ~= nil then
      return
    end
    if mqtt_client then
      return send_to_ubidots(jid, mqtt_client, client_id)
    end
  end
end

local function init_wifi(jid)
  print('WIFI: ...')
  local now, yield = tmr.now, coroutine.yield
  local timeout_at = now() + 10000000  -- 10s

  wifi.sta.config {ssid=CFG.ssid, pwd=CFG.pwd}
  wifi.sta.connect()

  local getip = wifi.sta.getip

  while timeout_at > now() do
    yield()
    if getip() then
      print('WIFI: up')
      return init_mqtt(jid)
    end
  end
end

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

local function to_signed_16bit(num)
  -- convert unsigned 16-bit to signed 16-bit
  if num > 32768 then
      num = num - 65536
  end
  return num
end

local function read_accel_temp(dev_addr)
  local bor, lshift, byte = bit.bor, bit.lshift, string.byte
  local ACCEL_XOUT_H =  0x3B

  local data = i2c_read(dev_addr, ACCEL_XOUT_H, 8)

  local ax = to_signed_16bit(bor(lshift(byte(data, 1), 8), byte(data, 2)))
  local ay = to_signed_16bit(bor(lshift(byte(data, 3), 8), byte(data, 4)))
  local az = to_signed_16bit(bor(lshift(byte(data, 5), 8), byte(data, 6)))
  local t  = to_signed_16bit(bor(lshift(byte(data, 7), 8), byte(data, 8)))

  return ax / 1638, ay / 1638, az / 1638, t / 34 + 365
end

local function init_i2c()
    -- initialize i2c, set pin1 as sda, set pin2 as scl
    i2c.setup(0, CFG.sda, CFG.scl, i2c.SLOW)

    wait(150)

    init_mpu6050(CFG.mpu6050_addr)
end

local function sample_accel_temp()
  init_i2c()

  local ax, ay, az, t = read_accel_temp(CFG.mpu6050_addr)

  send(ubidots, {accel_x=ax, accel_y=ay, accel_z=az, temperature=t})
end

local function sample_node()
  if adc.force_init_mode(adc.INIT_VDD33) then
    -- don't bother continuing, the restart is scheduled
    node.restart()
    return
  end
  local br1, br2 = node.bootreason()
  send(ubidots, {voltage=adc.readvdd33(), starts=rtcmem.read32(0), bootreason=br1*100 + br2, uptime=tmr.now()})
end

local function main(on_finished)

  ubidots = schedule(init_wifi)
  schedule(sample_accel_temp)
  schedule(sample_node)

  start(on_finished)
end

return main
