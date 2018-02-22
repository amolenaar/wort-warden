
-- # Stub implementation for NodeMCU node module
--
-- https://nodemcu.readthedocs.io/en/master/en/modules/node/
--
-- Only part of the module has been implemented.

local stub = require 'luassert.stub'

local node = {}

function node.bootreason()
  local ignore_me, extended_reset_cause = 0, 5
  return ignore_me, extended_reset_cause
end

-- function node.dsleep(us, option, instant)
-- end

stub(node, "dsleep")

return node
