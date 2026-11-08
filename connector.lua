connectors = {}

--[[

HOW A CONNECTOR WORKS

Each connector has an "id", a child node, and an activate "func"tion.

Hat connectors are manually called with other places in code.
Each hat connector procs itself with a function (activating all stickers), which procs its child node.
If its child node is a Rarity Change Connector, it will also check its function. If it returns TRUE, it also procs again. Recursively.

Procs can have their own data alongside these values, for example a "cooldown" extender would have a value for its cooldown.

Procs can also be forced.



]]

function connectors:init()
  connectors.list = {}
end

function connectors:make(ctype, c_args_)
  local ob = {}
  ob.rarity = connector_types.list[ctype].rarity or COMMON
  ob.type = ctype
  ob.c_args = c_args_ or connector_types.list[ctype].c_args or {nil,COMMON}
  ob.stickers = {}
  ob.extra = {}
  ob.perma_bonus = 0
  ob.times_triggered = 0
  return ob
end

function connectors:can_connect(a, b)
  if a == nil or b == nil then
    return true
  end
  local c1 = a.c_args[2]
  local c2 = b.c_args[1]

  if c1 == nil or c2 == nil then
    return false
  end
  return c1 >= c2
end

function connectors:proc(c, args, forced_, retriggered_)
  local ctype = connector_types.list[c.connector.type]

  local res = (ctype.func == nil) or (ctype.func(c, args) ~= false)

  if not res and not forced_ then
    return
  end

  play_sound("kwuh")
  c.pulse = 0.5

  c.connector.times_triggered = (c.connector.times_triggered or 0) + 1

  if c.connector.perma_bonus then
    game:gain(c.connector.perma_bonus)
  end

  --TODO: different sounds for common/uncommon/rare, maybe different sounds for extenders?


  if c.connector.c_args[1] ~= nil and c.connector.c_args[2] ~= nil then
    queues:queue({func = function()
      connectors:proc_all_with_type("extension")
    end}, 0.1)
  end

  if c.child then
    connectors:proc(c.child, args)
    if c.child.connector.rarity ~= nil and c.connector.rarity ~= nil and c.child.connector.rarity < c.connector.rarity and love.math.random(1,5) ~= 1 then
      queues:queue({func = function()
        connectors:proc_all_with_type("downgrade")
      end}, 0.1)
    end
  end

  if not retriggered_ then
    for a, b in ipairs(c.connector.stickers) do
      if b == "starbit" then
        connectors:proc(c, args, true, true)
      end
    end
  end

end

function connectors:proc_all_with_type(ctype, args)
  for i, j in ipairs(connector_ui.tiles) do
    if j.connector.type == ctype then
      connectors:proc(j, args)
    end
  end
end

function connectors:proc_all_when(whentype, args)
  for i, j in ipairs(connector_ui.tiles) do
    if connector_types.list[j.connector.type].check_when == whentype then
      connectors:proc(j, args)
    end
  end
end
















--Funny
