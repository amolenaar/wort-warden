

local _, boot = node.bootreason()
print("boot reason: "..tostring(boot))

if boot == 6 then
  rtcmem.write32(0, 1)
else
  local starts = rtcmem.read32(0)
  rtcmem.write32(0, starts + 1)
end

-- gpio.mode(4, gpio.INPUT, gpio.PULLUP)
-- local dev_mode = gpio.read(4)

local dev_mode = (boot == 6)

if dev_mode then
  print("In dev mode, awaiting user input")
  print("Call 'reboot()' to restore normal operation")
  function reboot()
    node.dsleep(1000000, 2) -- 1s
  end
else
  print("In prod mode")
  require('main')(function()
      node.dsleep(10000000, 2) -- 10s
    end)
end
