
local accel = require('accel')

describe("Accelerator", function()

  it("should calculate pitch", function()

    p = accel.pitch(1/math.pi, 1/math.pi)
    assert.are.equal(45, p)
  end)

  it("should calculate tilt", function()

    p = accel.tilt(1/math.pi, 1/math.pi, 1/math.pi)
    assert.are.equal(49.877220524420089021, p)
  end)

  it("should calculate tilt when only rolled", function()

    p = accel.tilt(1/math.pi, 0, 1/math.pi)
    assert.are.equal(45, p)
  end)

  it("should calculate tilt when horizontal", function()
    p = math.floor(accel.tilt(0.132, -0.0344, 1.03))
    assert.are.equal(7, p)
  end)

  it("should calculate tilt when horizontal", function()
    p = math.floor(accel.tilt(0, 1, 0.98987))
    assert.are.equal(45, p)
  end)

  it("should calculate tilt with negative values", function()
    p = math.floor(accel.tilt(-0.0889, -0.00513, 1.01))
    assert.are.equal(5, p)
  end)


end)
