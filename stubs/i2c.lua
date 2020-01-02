-- # Stub implementation for NodeMCU i2c module
--
-- https://nodemcu.readthedocs.io/en/master/en/modules/i2c/
--
-- Only part of the module has been implemented.

local i2c = {
  SLOW="SLOW",
  TRANSMITTER="TRANSMITTER",
  RECEIVER="RECEIVER"
}

function i2c.setup(id, pinSDA, pinSCL, speed)
  assert(id == 0)
  return 1
end

function i2c.start(id)
  assert(id == 0)
end

function i2c.address(id, device_addr, direction)
  assert(id == 0)
  return direction == i2c.TRANSMITTER -- allow to write
end

function i2c.read(id, len)
  assert(id == 0)
  assert(len == 8)

  return "12345678"
end

function i2c.write(id, data)
  assert(id == 0)
end

function i2c.stop(id)
  assert(id == 0)
end

return i2c
