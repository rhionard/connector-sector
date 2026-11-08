consumable_types = {
  applepacket = {
    func = function(c)
      game.stands["apple"] = (game.stands["apple"] or 0) + 1
      return true
    end,
    get_desc = function(c)
      return {
        "+1 permanent point to %rApples%!",
        "+" .. tostring(game.stands["apple"] or 1) .. " -> +" .. tostring((game.stands["apple"] or 1) + 1)
      }
    end,
    cost = 8
  },
  orangepacket = {
    func = function(c)
      game.stands["orange"] = (game.stands["orange"] or 0) + 1
      return true
    end,
    get_desc = function(c)
      return {
        "+1 permanent point to %oOranges%!",
        "+" .. tostring(game.stands["orange"] or 1) .. " -> +" .. tostring((game.stands["orange"] or 1) + 1)
      }
    end,
    cost = 6
  },
  bananapacket = {
    func = function(c)
      game.stands["banana"] = (game.stands["banana"] or 0) + 1
      return true
    end,
    get_desc = function(c)
      return {
        "+1 permanent point to %yBananas%!",
        "+" .. tostring(game.stands["banana"] or 2) .. " -> +" .. tostring((game.stands["banana"] or 2) + 1)
      }
    end,
    cost = 8
  },
  watermelonpacket = {
    func = function(c)
      game.stands["watermelon"] = (game.stands["watermelon"] or 0) + 1
      return true
    end,
    get_desc = function(c)
      return {
        "+1 permanent point to %gWatermelons%!",
        "+" .. tostring(game.stands["watermelon"] or 2) .. " -> +" .. tostring((game.stands["watermelon"] or 2) + 1)
      }
    end,
    cost = 7
  },
  grapepacket = {
    func = function(c)
      game.stands["grapes"] = (game.stands["grapes"] or 0) + 2
      return true
    end,
    get_desc = function(c)
      return {
        "+2 permanent points to %oGrapes%!",
        "+" .. tostring(game.stands["grapes"] or 1) .. " -> +" .. tostring((game.stands["grapes"] or 1) + 2)
      }
    end,
    cost = 6
  },
  blueberrypacket = {
    func = function(c)
      game.stands["blueberries"] = (game.stands["blueberries"] or 0) + 3
      return true
    end,
    get_desc = function(c)
      return {
        "+3 permanent points to %oBlueberries%!",
        "+" .. tostring(game.stands["blueberries"] or 3) .. " -> +" .. tostring((game.stands["blueberries"] or 3) + 3)
      }
    end,
    cost = 9
  },
  bombfruitpacket = {
    func = function(c)
      game.stands["bombfruit"] = (game.stands["bombfruit"] or 0) + 2
      return true
    end,
    get_desc = function(c)
      return {
        "+2 permanent point to %oBombfruit%!",
        "+" .. tostring(game.stands["bombfruit"] or 1) .. " -> +" .. tostring((game.stands["bombfruit"] or 1) + 2)
      }
    end,
    cost = 6
  },
  shoppingbag = {
    func = function(c, id)
      table.remove(consumable.owned, id)
      for i = 0, consumable.max - #consumable.owned do
        consumable:add(consumable:pick_random())
      end

      return false
    end,
    get_desc = function(c)
      return {
        "Make 3 random consumables"
      }
    end,
    cost = 12
  },
  starbit = {
    func = function(c, id)
      connector_ui.tiles = {}
      if game.state ~= "shop" then
        return false
      end

      for i, j in ipairs(shop.shops) do
        if j.type == "connector" then
          for k, l in ipairs(j.contents) do
            if j ~= -1 then
              l.connector.stickers = l.connector.stickers or {}
              table.insert(l.connector.stickers, "starbit")
            end
          end
        end
      end

      shop:open_menu(shop.shop_target)
      return true
    end,
    get_desc = function(c)
      return {
        "Add a Retrigger Sticker to all triggers in the shop",
        "Delete all owned triggers"
      }
    end,
    cost = 15,
    rarity = 2
  }
}

consumable = {}

function consumable:init(startup)
  consumable.owned = {}
  consumable.max = 3
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
  if #consumable.owned >= consumable.max then
    return
  end

  table.insert(consumable.owned, ob)
end

function consumable:draw_all(x, y)
  for a, b in ipairs(consumable.owned) do
    consumable:draw(b, x + a * 60, y)
  end
end

function consumable:use(c, cid) --  -> bool [successfully used]

  return consumable_types[c.type].func(c, cid)

end

function consumable:use_consumable(id)
  if #consumable.owned == 0 then
    return
  end
  if game.state ~= "shop" then
    connectors:proc_all_when("consumable", consumable.owned[#consumable.owned])
  end
  local used = consumable:use(consumable.owned[#consumable.owned], id)
  if used then
    table.remove(consumable.owned, #consumable.owned)
  end
end

function consumable:draw(c, x, y)
  love.graphics.setColor(1,1,1)
  love.graphics.draw(sprites["consumables/" .. c.type] or sprites["connector/bananas"], math.floor(x) - 50, math.floor(y) - 50, 0, 2)

  local mx, my = love.mouse.getX(), love.mouse.getY()
  local sx, sy = 70, 70
  if col(x - sx / 2, mx, y - sx / 2, my, 25, 25) then

    love.graphics.setColor(1,1,1)
    love.graphics.rectangle("fill", x + sx / 2 + 20, y - 50, sx * 3, sy)
    love.graphics.setColor(0,0,0)
    love.graphics.printf(consumable:get_desc(c), x + sx / 2 + 20, y - 50, sx * 3, "center")
  end
end

function consumable:get_desc(c)
  local txt = consumable_types[c.type].desc or connector_types.list["lol"].desc
  if consumable_types[c.type].get_desc then
    txt = consumable_types[c.type].get_desc(c)
  end

  return format_desc(txt)
end

function consumable:pick_random()

  local tc = {}
  for b, c in pairs(consumable_types) do
    table.insert(tc, {val = b, weight = c.rarity or 100})
  end
  return consumable:make(choose_weighted(tc), false)
end
