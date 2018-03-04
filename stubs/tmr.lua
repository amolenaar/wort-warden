-- # Stub implementation for NodeMCU tmr module
--
-- https://nodemcu.readthedocs.io/en/master/en/modules/tmr/
--
-- Only part of the module has been implemented.

local tmr = {
  ALARM_SINGLE="ALARM_SINGLE",
  -- Do not use: ALARM_SEMI="ALARM_SEMI",
  ALARM_AUTO="ALARM_AUTO"
}

local _timers = {}

function tmr.alarm(ref, interval_ms, mode, func)
  _timers[ref] = {mode, func}
end

function tmr.deregister(ref)
  _timers[ref] = nil
end

function tmr.run_all_timers()
  while next(_timers) ~= nil do
    for ref, mf in pairs(_timers) do
      mf[2](ref)
      if mf[1] == tmr.ALARM_SINGLE then
        tmr.deregister(ref)
      end
    end
  end
end

return tmr
