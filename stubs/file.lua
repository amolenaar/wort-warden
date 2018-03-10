-- # Stub implementation for NodeMCU file module
--
-- https://nodemcu.readthedocs.io/en/master/en/modules/file/
--
-- Only part of the module has been implemented.

local file = {}

function file.exists(filename)
   local f = io.open(filename, "r")
   if f ~= nil then
     io.close(f)
     return true
   else
     return false
   end
end

function file.open(filename, mode)
  local f = io.open(filename, mode)
  return f
end

function file.fsinfo()
  local remaining, used = 1234, 343
  return remaining, used, remaining + used
end

return file
