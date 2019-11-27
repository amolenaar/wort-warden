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
local _timer_ref = 1

local _now = 1
function tmr.now()
  _now = _now + 1
  return _now
end

function tmr.delay(interval_us)
  -- noop
end

local Timer = {}
Timer.__index = Timer

function tmr.create()
  local timer = setmetatable({}, Timer)
  return timer
end

function Timer:alarm(interval_ms, mode, func)
  self.mode = mode
  self.func = func

  self.timer_ref = _timer_ref
  _timers[_timer_ref] = self
  _timer_ref = _timer_ref + 1
end

function Timer:unregister()
  _timers[self.timer_ref] = nil
end

function Timer:run()
  self.func(self)
  if self.mode == tmr.ALARM_SINGLE then
    self:unregister()
  end
end

function tmr.run_all_timers()
  while next(_timers) ~= nil do
    for ref, mf in pairs(_timers) do
      mf:run()
    end
  end
end

return tmr
