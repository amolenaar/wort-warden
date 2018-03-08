globals = {
  "nil",
  "node",
  "file",
  "i2c",
  "tmr",
  "wifi"
}

files["src/scheduler.lua"].ignore = {
  "431" -- shadowing upvalue
}
