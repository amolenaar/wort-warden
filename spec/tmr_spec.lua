require('stubs.bootstrap')

describe("Timer", function()

  it("should execute a single alarm", function()
    local value

    tmr.alarm(1, 0, tmr.ALARM_SINGLE, function()
      value = "been there"
    end)

    tmr.run_all_timers()

    assert.are.equal("been there", value)
  end)

  it("should execute a auto alarm", function()
    local counter = 0

    tmr.alarm(1, 0, tmr.ALARM_AUTO, function(ref)
      counter = counter + 1
      if counter > 9 then
        tmr.unregister(ref)
      end
    end)

    tmr.run_all_timers()

    assert.are.equal(10, counter)
  end)

  it("should rerun", function()
    local value

    tmr.alarm(1, 0, tmr.ALARM_SINGLE, function()
      value = "been there"
    end)

    tmr.run_all_timers()

    assert.are.equal("been there", value)

    tmr.alarm(1, 0, tmr.ALARM_SINGLE, function()
      value = "been there too"
    end)

    tmr.run_all_timers()

    assert.are.equal("been there too", value)

  end)

end)
