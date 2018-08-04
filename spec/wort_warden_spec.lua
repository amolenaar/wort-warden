
require('stubs.bootstrap')

describe("Once configured", function()

  setup(function()
  end)

  it("perform a sampling cycle", function()
    dofile('src/main.lua')()
    node.main_loop()

    assert.are.equal(2, #mqtt.messages_sent())
    assert.are.equal('{"bootreason": 5, "starts": 1, "uptime": 4, "voltage": 3300}', mqtt.messages_sent()[1])
    assert.are.equal('{"accel_x": 7, "accel_y": 8, "accel_z": 8, "temperature": 780, "tilt": 48}', mqtt.messages_sent()[2])
    -- assert.stub(node.dsleep).was_called_with(0)
  end)

end)
