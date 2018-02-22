

describe("Once configured", function()

  setup(function()
    require('stubs.bootstrap')
    require('main')()

  end)

  it("should measure temperature", function()

  end)

  it("should measure orientation", function()
  end)

  it("should measure system information", function()
  end)

  it("should send measurements over MQTT", function()
  end)

  it("should perform a deep sleep when done", function()

    assert.stub(node.dsleep).was_called_with(0)
  end)

end)
