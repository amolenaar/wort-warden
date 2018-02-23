

require('stubs.bootstrap')
require('scheduler')

describe("The scheduler", function()

  it("should execute a function", function()
    local value
    schedule(function()
      value = "been there"
    end)

    start()
    tmr.run_all_timers()

    assert.are.equal("been there", value)
  end)

  it("should allow function to yield", function()
    local value

    schedule(function()
      value = "been"
      coroutine.yield()
      value = value.." "
      coroutine.yield()
      value = value.."there"
    end)

    start()
    tmr.run_all_timers()

    assert.are.equal("been there", value)
  end)

  it("should allow multiple functions", function()
    local value

    schedule(function()
      value = "been"
    end)
    schedule(function()
      coroutine.yield()
      value = value.." "
      coroutine.yield()
      value = value.."there"
    end)

    start()
    tmr.run_all_timers()

    assert.are.equal("been there", value)
  end)

end)



describe("Scheduled routines", function()

  it("should be able to send messages to each other", function()
    local value

    local consumer = schedule(function()
      while not value do
        value = coroutine.yield()
      end
    end)

    -- producer
    schedule(function()
      coroutine.yield(consumer, "been there")
    end)

    start()
    tmr.run_all_timers()

    assert.are.equal("been there", value)
  end)

  it("should be able to schedule jobs themselves", function()
    local value
    local outer

    outer = schedule(function()
      local inner = schedule(function()
        coroutine.yield(outer, "been there")
      end)

      while not value do
        value = coroutine.yield()
      end
    end)

    start()
    tmr.run_all_timers()

    assert.are.equal("been there", value)
  end)

end)
