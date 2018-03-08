
local CFG = require('config')

-- local function measure_temperature(dev_addr)
--   i2c.start(0)
--   i2c.address(0, dev_addr, i2c.RECEIVER)
--   c = i2c.read(0, 1)
--   i2c.stop(0)
--   return c
-- end

-- local function measure_angle(dev_addr)
--   -- Perform i2c config only on cold boot. If started from deep sleep, it should not be nessecary
--   i2c.start(0)
--   i2c.address(0, dev_addr, i2c.RECEIVER)
--   c = i2c.read(0, 1)
--   i2c.stop(0)
--   return c
-- end

-- local function enable_wifi(timer_id)

--   local ip = wifi.sta.getip()

--   if(ip==nil) then
--     print("Connecting...")
--   else
--    tmr.stop(timer_id)
--    print("Connected to AP!")
--    print(ip)
--       -- make a call with a voice message "your house is on fire"
--    -- make_call("15558976687","1334856679","Your house is on fire!")
--   end

-- end

-- luacheck: ignore 111
-- function main()

  wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, function(ssid)
    print("Wifi connected - from registered handler")
    the_ssid = ssid
  end)

  -- check IP here - we missed the Connected event

  local sda = 1
  local scl = 2

  -- initialize i2c, set pin1 as sda, set pin2 as scl
  i2c.setup(0, sda, scl, i2c.SLOW)

  -- TODO: run coroutines from a single timer/alarm.
  -- TODO: allow for a way to send messages to other coroutines
  -- tmr.alarm(0, 0, tmr.ALARM_SINGLE, measure_temperature)
  -- tmr.alarm(1, 0, tmr.ALARM_SINGLE, measure_angle)

  wifi.sta.config {ssid=CFG.ssid, pwd=CFG.pwd}
  wifi.sta.connect()
  -- tmr.alarm(2, 1000, tmr.ALARM_AUTO, enable_wifi)
  -- measure temperature2
  -- measure angle
  -- enable wifi
  -- send message
  -- node.dsleep(0)
-- end

-- luacheck: ignore 113
-- main()

function send_to_ubidots()
  local CLIENT_ID=tostring(node.chipid())

  m = mqtt.Client(CLIENT_ID, 120, CFG.token, "")

  m:on("connect", function(client) print ("connected") end)
  m:on("offline", function(client) print ("offline") end)

  m:connect("things.ubidots.com", 1883, 0, function(client)
    print("connected")
    -- Calling subscribe/publish only makes sense once the connection
    -- was successfully established. You can do that either here in the
    -- 'connect' callback or you need to otherwise make sure the
    -- connection was established (e.g. tracking connection status or in
    -- m:on("connect", function)).

    -- subscribe topic with qos = 0
    -- client:subscribe("/topic", 0, function(client) print("subscribe success") end)
    -- publish a message with data = hello, QoS = 0, retain = 0
    -- client:publish("/topic", "hello", 0, 0, function(client) print("sent") end)
    client:publish("/v1.6/devices/"..CLIENT_ID, '{"temperature": 18}', 0, 0, function(client) print("sent") end)

  end,
  function(client, reason)
    print("failed reason: " .. reason)
  end)
end
