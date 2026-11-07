--A list of queues of events. That's   the thing.

queues = {}

function queues:init()
  queues = {}
end

function queues:queue(q, t, pauser)
  table.insert(queues, {{q, time = t, unpausable = pauser}})
end

function queues:clear()
  for a = #queues, 1, -1 do
    if type(queues[a]) == "table" and queues[a][1].unpausable then
      table.remove(queues, a)
    end
  end
end

function queues:update(dt)

  local pdels = {}

  for i, j in ipairs(queues) do

    local dels = {}

    for k, l in ipairs(j) do
      if l.unpausable or not game.pause then
        l.time = l.time - dt
      end

      if l.time <= 0 then
        if l[1].func then l[1].func(l) end
        table.insert(dels, k)
      end

    end

    for a = #dels, 1, -1 do
      table.remove(j, dels[a])
    end

    if #j == 0 then
      table.insert(pdels, i)
    end
  end

  for a = #pdels, 1, -1 do
    table.remove(queues, pdels[a])
  end

end
