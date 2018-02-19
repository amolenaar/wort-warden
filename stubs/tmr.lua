-- # Stub implementation for NodeMCU tmr module
--
-- https://nodemcu.readthedocs.io/en/master/en/modules/tmr/
--
-- Only part of the module has been implemented.

local tmr = {
  ALARM_SINGLE="ALARM_SINGLE",
  ALARM_SEMI="ALARM_SEMI",
  ALARM_AUTO="ALARM_AUTO"
} 

tmr._timers = {}

function tmr.alarm(ref, interval_ms, mode, func)
  -- start coroutine to run func(ref)
  table.insert(tmr._timers, coroutine.create(function() func(ref) end))
end

function tmr.run_all_timers()
  for i = 1, #tmr._timers do
    corouine.resume(tmr._timers[i])
  end
end

return tmr
