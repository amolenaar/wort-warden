
require('stubs.bootstrap')

describe("Once configured", function()

  setup(function()
  end)

  it("perform a sampling cycle", function()
    dofile('src/main.lua')()
    node.main_loop()

    assert.are.equal(2, #mqtt.messages_sent())
    assert.are.equal('{"bootreason": 5, "starts": 1, "uptime": 4, "voltage": 3300}', mqtt.messages_sent()[1])
    -- assert.are.equal('{"accel_x": 787, "accel_y": 819, "accel_z": 851, "temperature": 78, "tilt": 49}', mqtt.messages_sent()[2])
    assert.are.equal('{"accel_x": 0.7686767578125, "accel_y": 0.800048828125, "accel_z": 0.8314208984375, "temperature": 78.106470588235, "tilt": 124.77917552831}', mqtt.messages_sent()[2])

    -- assert.stub(node.dsleep).was_called_with(0)
  end)

end)
