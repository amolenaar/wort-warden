
require('stubs.bootstrap')

describe("Once configured", function()

  setup(function()
  end)

  it("perform a sampling cycle", function()
    dofile('src/main.lua')
    node.main_loop()

    assert.are.equal(1, #mqtt.messages_sent())
    assert.are.equal('{"starts": 1, "voltage": 3300}', mqtt.messages_sent()[1])
    -- assert.stub(node.dsleep).was_called_with(0)
  end)

end)
