# The Scheduler
#
# The scheduler allows your program to execute multiple jobs at once.
# This scheduler is (very) loosely inspired by BEAM, the Erlang VM.
# Each job should be modeled as a Lua coroutine.
#
# Functions:
#
# schedule(func) -> jid
#   Add a function `func()` to the scheduler, return a job identifier. Jobs are only executed
#   when the `start()` is called. Jobs can be scheduled when the scheduler is running.
# start(on_finished) -> nil
#   Start the scheduler. `on_finished()` will be called when all jobs are finished.
# wait(ms) -> nil
#   Suspend processing of the job for `ms` milliseconds.
# send(jid, msg) -> nil
#   Send a message to a job, identified by its job id (JID). `msg` can be any lua construct.
#   After sending the sent message object should not be changed.
# recieve(timeout) -> msg | "TIMEOUT!"
#   Recieve a message sent to the current job. Timeout in milliseconds.
#

local function qnew()
    return {first = 0, last = -1}
end

local function qpush(q, value)
    local first = q.first - 1
    q.first = first
    q[first] = value
end

local function qpop(q)
    local last = q.last
    if q.first > last then return nil, "queue is empty" end
    local value = q[last]
    q[last] = nil -- to allow garbage collection
    q.last = last - 1
    return value
end

local job_list = {}
local next_job_id = 1
local job_id = nil
local yield = coroutine.yield

function schedule(func)
  local jid = next_job_id
  job_list[jid] = {coroutine.create(func), qnew()}
  next_job_id = next_job_id + 1
  return jid
end

function start(on_finished)
  local loop = coroutine.create(function()
    local next = next
    local resume, status = coroutine.resume, coroutine.status
    local _, err
    while next(job_list) ~= nil do
      for id, aq in pairs(job_list) do
        job_id = id
        _, err = resume(aq[1], id)
        job_id = nil
        if err then
          print('Coroutine failed: '..err)
        end
        if err or status(aq[1]) == "dead" then
          job_list[id] = nil
        end
        yield()
      end
    end
  end)

  local resume = coroutine.resume
  -- Put a 10ms interval here, to avoid busy waiting
  local timer = tmr.create()
  timer:alarm(10, tmr.ALARM_AUTO, function()
    if not resume(loop) then
      timer:unregister()
      if on_finished then on_finished() end
    end
  end)
end

function wait(ms)
  while ms > 0 do
    yield()
    ms = ms - 10
  end
end

function send(jid, msg)
  if job_list[jid] then
    qpush(job_list[jid][2], msg)
  else
    print("Cannot send message "..tostring(msg).." to jid "..tostring(jid))
  end
end

-- Receive data. timeout is counted in cycles. One cycle is roughly 10ms
-- Return a message, or "TIMEOUT!" if the timeout has been reached
function receive(timeout)
  if timeout == nil then timeout = 99 end
  local q = job_list[job_id][2]
  while timeout > 0 do
    local msg = qpop(q)
    if msg ~= nil then
      return msg
    end
    timeout = timeout - 1
    yield()
  end
  return "TIMEOUT!"
end
