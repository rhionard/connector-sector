consumable_types = {
  applepacket = {
    func = function(c)
      game.stands["apple"] = (game.stands["apple"] or 0) + 1
      return true
    end,
    cost = 8
  },
  orangepacket = {
    func = function(c)
      game.stands["orange"] = (game.stands["orange"] or 0) + 1
      return true
    end,
    cost = 6
  },
  bananapacket = {
    func = function(c)
      game.stands["banana"] = (game.stands["banana"] or 0) + 1
      return true
    end,
    cost = 8
  },
  watermelonpacket = {
    func = function(c)
      game.stands["watermelon"] = (game.stands["watermelon"] or 0) + 1
      return true
    end,
    cost = 7
  },
  grapepacket = {
    func = function(c)
      game.stands["grapes"] = (game.stands["grapes"] or 0) + 2
      return true
    end,
    cost = 6
  },
  blueberrypacket = {
    func = function(c)
      game.stands["blueberries"] = (game.stands["blueberries"] or 0) + 3
      return true
    end,
    cost = 9
  },
  bombfruitpacket = {
    func = function(c)
      game.stands["bombfruit"] = (game.stands["bombfruit"] or 0) + 2
      return true
    end,
    cost = 6
  }
}

consumable = {}

function consumable:init(startup)
  consumable.owned = {}
end

function consumable:make(t, add)
  local ob = {}
  ob.type = t
  if not add then
    return ob
  end
  table.insert(consumable.owned, ob)
end

function consumable:add(ob)
  table.insert(consumable.owned, ob)
end

function consumable:draw_all(x, y)
  for a, b in ipairs(consumable.owned) do
    consumable:draw(b, x + a * 60, y)
  end
end

function consumable:use(c) --  -> bool [successfully used]

  return consumable_types[c.type].func(c)

end

function use_consumable(id)
  if #consumable.owned == 0 then
    return
  end
  if game.state ~= "shop" then
    connectors:proc_all_when("consumable", consumable.owned[#consumable.owned])
  end
  consumable:use(consumable.owned[#consumable.owned])
  table.remove(consumable.owned, #consumable.owned)
end

function consumable:draw(c, x, y)
  love.graphics.setColor(1,1,1)
  love.graphics.draw(sprites["consumables/" .. c.type], math.floor(x) - 50, math.floor(y) - 50, 0, 2)
end

function consumable:pick_random()
  local tc = {}
  for b, c in pairs(consumable_types) do
    table.insert(tc, b)
  end
  return consumable:make(tc[love.math.random(1, #tc)], false)
end
