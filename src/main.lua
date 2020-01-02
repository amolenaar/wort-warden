
require('scheduler')
local CFG = require('config')
local gy521 = require('gy521')

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

-- Networking

local function init_wifi()
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
      return true
    end
  end
  print('WIFI: down')
end

local function init_mqtt(client_id)
  print('MQTT: ...')
  local now, yield = tmr.now, coroutine.yield
  local timeout_at = now() + 10000000 -- 10s
  local mqtt_client, failed
  local m = mqtt.Client(client_id, 120, CFG.token, "")

  m:connect("things.ubidots.com", 1883, 0, 0,
    function(client)
      print('MQTT: up')
      mqtt_client = client
    end,
    function(client, reason)
      print('MQTT: '..tostring(client).." failed, "..reason)
      failed = reason
    end)

  while timeout_at > now() do
    yield()
    if failed ~= nil then
      return
    end
    if mqtt_client then
      return mqtt_client --send_to_ubidots(jid, mqtt_client, client_id)
    end
  end
end

local function send_to_ubidots(client, client_id)
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

  return send_to_ubidots(client, client_id)
end

local function sender()
  if init_wifi() then
    local client_id = tostring(node.chipid())
    local client = init_mqtt(client_id)
    if client then
      send_to_ubidots(client, client_id)
    end
  end
end


local function sample_accel_temp()
  gy521.init(CFG.sda, CFG.scl, CFG.mpu6050_addr)

  wait(150)

  local ax, ay, az, t = gy521.read_accel_temp(CFG.mpu6050_addr)

  send(ubidots, {accel_x=ax, accel_y=ay, accel_z=az, temperature=t, tilt=gy521.tilt(ax, ay,az)})

  gy521.sleep(CFG.mpu6050_addr)
end

-- Sample diagnostics info

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

  ubidots = schedule(sender)
  schedule(sample_accel_temp)
  schedule(sample_node)

  start(on_finished)
end

return main
