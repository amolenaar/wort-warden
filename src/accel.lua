
local PI = math.pi
local RAD =  PI / 180  -- degr to radian

local function atan (x0)
  -- in radian

  -- https://stackoverflow.com/questions/11930594/calculate-atan2-without-std-functions-or-c99
  -- excellect formula for 0 - 45degr [ie atan(x) for x<1] but runs away badly for x very large
  -- but we can cheat using symmetry of atan(x) and atan(1/x) around 45degr (0 - 45 - 90)
  local x = x0
  local c = (1 + math.sqrt(17)) / 8
  if x0 < 0 then x = -x0 end
  if x0 > 1  then x = 1/x end
  local a =  (c * x + x*x + math.pow(x, 3)) / ( 1 + (c + 1) * x + (c + 1) * x*x + math.pow(x,3)) * PI/2
  if x0 > 1  then a = PI/2 - a end
  if x0 < 0 then a = -a end
  return a
end

local function atan2(aw, az)
    -- in radian

    local a = atan(aw / az)
    -- https://en.wikipedia.org/wiki/Atan2#Definition
    if az > 0 then return a end
    if az < 0 then
        if aw >= 0 then return a + PI end
        return a - PI
    end
    if aw > 0 then return PI / 2 end
    if aw < 0 then return (-PI / 2) end
    return 0 -- undef??
end

local function roll(ax , az)
    -- in integer degrees
    return - math.floor(atan2(ax, az)/RAD)
end

local function pitch(ay , az)
    -- in integer degrees
    return math.floor(atan2(ay, az)/RAD)
end

local function tilt(ax, ay, az)
  local sqrt = math.sqrt
  local p = pitch(ay, sqrt(ax * ax + az * az))
  local r = roll(ax, sqrt(ay * ay + az * az))

  return sqrt(p * p + r * r)
end

return {
  tilt=tilt,
  pitch=pitch,
  roll=roll
}
