-- # Stub implementation for NodeMCU wifi module
--
-- https://nodemcu.readthedocs.io/en/master/en/modules/wifi/
--
-- Only part of the module has been implemented.

local wifi = {
  STATION="STATION",
  SOFTAP="SOFTAP",
  STATIONAP="STATIONAP",
  sta={},
  ap={},
}

local state = {}

wifi.stub_state = state

function wifi.setmode(mode, save)
  state.mode = mode
end

function wifi.sta.autoconnect(auto)
  state.sta_autoconnect = auto
end

function wifi.sta.config(station_config)
  state.sta_station_config = station_config
end

return wifi
