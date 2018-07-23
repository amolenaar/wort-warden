

local _, boot = node.bootreason()
if boot == 6 then
  rtcmem.write32(0, 1)
else
  local starts = rtcmem.read32(0)
  rtcmem.write32(0, starts + 1)
end

-- gpio.mode(4, gpio.INPUT, gpio.PULLUP)
local dev_mode = 0 --gpio.read(4)

if dev_mode == 0 then
  print("In dev mode, awaiting user input")
else
  print("In prod mode")
  require('main')(function()
      node.dsleep(10000000, 2) -- 10s
    end)
end
