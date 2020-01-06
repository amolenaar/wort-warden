
require('scheduler')
local CFG = require('config')
local accel = require('accel')
local gy521 = require('gy521')

local ubidots

-- Networking

local function init_wifi()
  print('WIFI: init')
  local now, yield = tmr.now, coroutine.yield
    local timeout_at = now() + 10000000  -- 10s

  wifi.setmode(wifi.STATION)
  wifi.sta.config {ssid=CFG.ssid, pwd=CFG.pwd, auto=true}

  local getip = wifi.sta.getip

  while timeout_at > now() do
    yield()
    if getip() then
      print('WIFI: up '..tostring(getip()))
      return true
    end
  end
  print('WIFI: down')
end

local function init_mqtt(client_id)
  print('MQTT: init')
  local now, yield = tmr.now, coroutine.yield
  local timeout_at = now() + 10000000 -- 10s
  local mqtt_client, failed
  local m = mqtt.Client(client_id, 120, CFG.token, "")

  m:connect("industrial.api.ubidots.com", 1883, false,
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
  gy521.init()

  local count = 0
  local rounds = 8
  local ax_t, ay_t, az_t, t_t = 0.0, 0.0, 0.0, 0.0
  local ax, ay, az, t

  while count < rounds do
    --wait(100)
    ax, ay, az, t = gy521.read_accel_temp()
    ax_t = ax_t + ax
    ay_t = ay_t + ay
    az_t = az_t + az
    t_t = t_t + t
    count = count + 1
  end

  ax = ax_t / rounds
  ay = ay_t / rounds
  az = math.abs(az_t / rounds)
  t = t_t / rounds

  send(ubidots, {accel_x=ax, accel_y=ay, accel_z=az, temperature=t, pitch=accel.pitch(ay, az), roll=accel.roll(ax, az)})

  gy521.sleep()
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
