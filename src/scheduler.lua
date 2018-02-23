
local queue = {}

function queue.new()
    return {first = 0, last = -1}
end

function queue.push(q, value)
    local first = q.first - 1
    q.first = first
    q[first] = value
end

function queue.pop(q)
    local last = q.last
    if q.first > last then return nil, "queue is empty" end
    local value = q[last]
    q[last] = nil -- to allow garbage collection
    q.last = last - 1
    return value
end

function queue.empty(q)
    return q.first > q.last and true or false
end


job_list = {}
local job_id = 0

function schedule(func)
  job_id = job_id + 1
  job_list[job_id] = {coroutine.create(func), queue.new()}
  return job_id
end

send_receive = coroutine.yield

function start()
  local loop = coroutine.create(function()
    local job_list, next = job_list, next
    local yield, resume, status = coroutine.yield, coroutine.resume, coroutine.status
    local push, pop = queue.push, queue.pop
    local st, dp, dm
    while next(job_list) ~= nil do
      for id, aq in pairs(job_list) do
        st, dp, dm = resume(aq[1], pop(aq[2]))
        if dp and dm ~= nil then
          local tg = job_list[dp]
          if tg then
            push(tg[2], dm)
          end
        end
        if not st or status(aq[1]) == "dead" then
          job_list[id] = nil
        end
        yield()
      end
    end
  end)

  local resume = coroutine.resume
  tmr.alarm(1, 0, tmr.ALARM_AUTO, function(timer_id)
    if not resume(loop) then
      tmr.deregister(timer_id)
    end
  end)
end