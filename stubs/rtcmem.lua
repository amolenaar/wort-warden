-- # Stub implementation for NodeMCU node module
--
-- https://nodemcu.readthedocs.io/en/master/en/modules/rtcmem/
--
-- Only part of the module has been implemented.

local rtcmem = {}

function rtcmem.read32(idx)
  return 1
end

function rtcmem.write32(idx, v)
end

return rtcmem
