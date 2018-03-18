-- Fast XY vector to integer degree algorithm - Jan 2011 www.RomanBlack.com
-- https://www.romanblack.com/integer_degree.htm
--
-- Converts any XY values including 0 to a degree value that should be
-- within +/- 1 degree of the accurate value without needing
-- large slow trig functions like ArcTan() or ArcCos().
-- This is the full version, for all 4 quadrants and will generate
-- the angle in integer degrees from 0-360.
-- Any values of X and Y are usable including negative values provided
-- they are between -47721858 and 47721858 so the 32 bit multiply does not overflow.

local function atan2(x, y)
  if x == 0 and y == 0 then return 0 end

  local x_neg_flag, y_neg_flag, octant_flag

  -- Save the sign flags then remove signs and get XY as unsigned ints
  if x < 0 then
    x = -x
    x_neg_flag = 1
  end

  if y < 0 then
    y = -y
    y_neg_flag = 1
  end

  -- 1. Calc the scaled "degrees"
  local degree
  if x > y then
    degree = (y * 45) / x   -- degree result will be 0-45 range
    octant_flag = 1
  else
    degree = (x * 45) / y   -- degree result will be 0-45 range
  end

  -- 2. Compensate for the 4 degree error curve
  local comp = 0
  if degree > 22 then
    if degree <= 44 then comp = comp + 1 end
    if degree <= 41 then comp = comp + 1 end
    if degree <= 37 then comp = comp + 1 end
    if degree <= 32 then comp = comp + 1 end
  else
    if degree >= 2  then comp = comp + 1 end
    if degree >= 6  then comp = comp + 1 end
    if degree >= 10 then comp = comp + 1 end
    if degree >= 15 then comp = comp + 1 end
  end
  degree = degree + comp -- degree is now accurate to +/- 1 degree!

  -- Invert degree if it was X > Y octant, makes 0-45 into 90-45
  if octant_flag then degree = 90 - degree end

  -- 3. Degree is now 0-90 range for this quadrant,
  -- need to invert it for whichever quadrant it was in
  if x_neg_flag and y_neg_flag then
    degree = 180 + degree
  elseif y_neg_flag then
    degree = 180 - degree
  elseif x_neg_flag then
    degree = 360 - degree
  end

  return degree
end

return atan2
