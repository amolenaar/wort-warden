
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
function main()

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

  wifi.sta.config {ssid="xx", pwd="xx"}
  wifi.sta.connect()
  -- tmr.alarm(2, 1000, tmr.ALARM_AUTO, enable_wifi)
  -- measure temperature2
  -- measure angle
  -- enable wifi
  -- send message
  -- node.dsleep(0)
end

-- luacheck: ignore 113
main()
