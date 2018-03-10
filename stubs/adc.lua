-- # Stub implementation for NodeMCU adc module
--
-- https://nodemcu.readthedocs.io/en/master/en/modules/adc/
--
-- Only part of the module has been implemented.

local adc = {
  INIT_VDD33="INIT_VDD33"
}

function adc.force_init_mode(mode_value)
  return false
end

function adc.readvdd33()
  return 3300
end

return adc
