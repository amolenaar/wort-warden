-- # Stub implementation for NodeMCU node module
--
-- https://nodemcu.readthedocs.io/en/master/en/modules/node/
--
-- Only part of the module has been implemented.

local sjson = {}

function sjson.encode(msg)
  if type(msg) == "table" then
    local json = '{'
    local first = true
    local fields = {}
    -- Do this intermediate step to enforce order
    for k, v in pairs(msg) do
      table.insert(fields, '"'..tostring(k)..'": '..tostring(v))
    end
    table.sort(fields)
    for i, v in ipairs(fields) do
      if not first then
        json = json..', '
      end
      first = false
      json = json..v
    end
    return json..'}'
  end
  return tostring(msg)
end

return sjson
