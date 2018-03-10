

local _, boot = node.bootreason()
if boot == 6 then
  rtcmem.write32(0, 1)
else
  local starts = rtcmem.read32(0)
  rtcmem.write32(0, starts + 1)
end

require('main')()
