
local accel = require('accel')

describe("Accelerator", function()

  it("should calculate pitch", function()

    p = accel.pitch(1/math.pi, 1/math.pi)
    assert.are.equal(45, p)
  end)

  it("should calculate tilt", function()

    p = accel.tilt(1/math.pi, 1/math.pi, 1/math.pi)
    assert.are.equal(49.497474683058328537, p)
  end)

  it("should calculate tilt when only rolled", function()

    p = accel.tilt(1/math.pi, 0, 1/math.pi)
    assert.are.equal(45, p)
  end)

  it("should calculate tilt when horizontal", function()
    p = accel.tilt(0.132, -0.0344, 1.03)
    assert.are.equal(7, math.floor(p))
  end)

  it("should calculate tilt when horizontal", function()
    p = accel.tilt(0, 1, 0.98987)
    assert.are.equal(45, p)
  end)

  it("should calculate tilt with negative values", function()
    p = accel.tilt(-0.0889, -0.00513, 1.01)
    assert.are.equal(6, math.floor(p))
  end)


end)
