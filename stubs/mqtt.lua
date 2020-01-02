-- # Stub implementation for NodeMCU node module
--
-- https://nodemcu.readthedocs.io/en/master/en/modules/mqtt/
--
-- Only part of the module has been implemented.

local mqtt = {}

local Client = {}
Client.__index = Client

local payloads = {}

function mqtt.Client(msg)
  local client = setmetatable({}, Client)
  return client
end

function Client:connect(host, port, secure, on_connect, on_error)
  on_connect(self)
  -- print("MQTT client connected")
end

function Client:close()
  -- print("MQTT client closed")
end

function Client:publish(topic, payload, qos, retain, on_sent)
  table.insert(payloads, payload)
  if on_sent then on_sent(self) end
end

function mqtt.messages_sent()
  return payloads
end

return mqtt
