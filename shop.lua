shop = {}

--[[
For the shop, i want 1. objects in the overworld that resemble shops and 2. different types of shops for different      items

Each shop will probably be another game object, with a menu attached
--]]
shop_types = {
  connector = {
    populate = function()

      local res = {}
      local exclusions = {}
      for a, b in ipairs(connector_ui.tiles) do
        exclusions[b.connector.type] = true
      end
      for a, b in pairs(shop.frozen_items) do
        exclusions[b.button.connector_ui.connector.type] = true
      end
      for a = 1, 8 do
        local b = shop:make_connector(exclusions)
        if b ~= nil then

          if shop.frozen_items[a] then
            table.insert(res, shop.frozen_items[a].button.connector_ui)
          else

            local connec = connector_ui:add_tile(b, true)

            shop:adjust_connector(connec)

            table.insert(res, connec)
            exclusions[ b ] = true

          end
        end
      end
      return res
    end
  },
  fruit = {
    populate = function()
      local res = {}
      for a = 1, 8 do
        local b = {fruit = fruit_types:random(), bonuses = {}}
        if love.math.random(1,12) == 1 then
          local q = fruit:random_bonus()
          b.bonuses[q] = true
        end
        table.insert(res, b)
      end
      return res

    end
  },
  consumable = {
    populate = function()
      local res = {}
      for a = 1, 4 do
        table.insert(res, consumable:pick_random())
      end
      return res

    end,
    off = 0.25
  }
}

function shop:adjust_connector(connec)
  if connec.connector.c_args[1] ~= nil and connec.connector.c_args[2] == nil and love.math.random(1, 80) == 1 then
    connector_ui:change_args(connec, connec.connector.c_args[1], connec.connector.c_args[1])
    connec.modified = true
  end

end


function shop:make_connector(exclusions_)
  local rand_connect = {}
  local exclusions = exclusions_ or {}
  for i, j in pairs(connector_types.list) do
    if not exclusions[i] then
      table.insert(rand_connect, {val = i, weight = connector_types:get_weight(j.rarity)})
    end
  end
  return choose_weighted(rand_connect)
end

function choose_weighted(tab) -- table with each value being {val, weight}
  local total = 0
  for a, b in ipairs(tab) do
    total = total + b.weight
  end
  local randval = love.math.random(1, total)
  for a, b in ipairs(tab) do
    randval = randval - b.weight
    if (randval < 0) then
      return b.val
    end
  end
  if #tab == 0 then
    return
  end
  return tab[#tab].val
end

function shop:init()
  shop.shops = {}
  shop.open_shop = {}
  shop.close = true

  shop.ease_level = 0
  shop.ease_timer = 0
  shop.ease_target = 0
  shop.ease_time = 0

  shop.frozen_items = shop.frozen_items or {}

  smartmenu:add(shop.open_shop)

  shop:add("connector", 20)
  shop:add("fruit", 480)
  shop:add("consumable", 940)
end

function shop:add(t, x, y_)
  local ob = {}
  ob.type = t
  ob.x = x
  ob.y = FLOOR
  ob.sizex = 180
  ob.sizey = 120
  ob.contents = shop_types[t].populate()
  ob.reroll_price = 5
  ob.reroll_mod = game.reroll_mod or 0
  game.reroll_mod = 0
  table.insert(shop.shops, ob)
end

function shop:draw()
  for i, j in ipairs(shop.shops) do
    love.graphics.setColor(0.2,0.7,0.8)
    love.graphics.rectangle("fill", j.x - 25, j.y - 35 - j.sizey / 2, j.sizex, j.sizey)
  end
end

function shop:update(dt)
  if shop.ease_timer > 0 then
    shop.ease_timer = shop.ease_timer - dt
  end
end

function shop:ease()
  shop.ease_level = -700
  shop.ease_target = 0
  shop.ease_time = 0.5
  shop.ease_timer = 0.5

end

function shop:ease_out()
  shop.ease_level = 0
  shop.ease_target = -700
  shop.ease_time = 0.5
  shop.ease_timer = 0.5
end

function shop:draw_menu()
  if shop.open_shop then
    --[[
    local mx, my = love.mouse.getX(), love.mouse.getY()
    love.graphics.setColor(0.2, 0.2, 0.3)
    love.graphics.rectangle("fill", 10, 10, wx * 2 / 3 - 20, wy / 2)
    for i, j in ipairs(shop.open_shop) do
      local x, y = j.x, j.y
      local sizex, sizey = j.sizex, j.sizey
      love.graphics.setColor(0.3, 0.3, 0.45)
      if col(j.x + j.sizex / 2, mx, j.y + j.sizey / 2, my, j.sizex / 2, j.sizey / 2) then
        love.graphics.setColor(0.4, 0.4, 0.55)
      end
      love.graphics.rectangle("fill", x, y, sizex, sizey)
      shop_draw_funcs[shop.shop_target.type](j, x, y, sizex, sizey)

      love.graphics.setColor(1,1,1)
      love.graphics.printf(j.cost .. "$", x, y + sizey, sizex, "center")

    end
    --]]
    smartmenu_drawone(shop.open_shop, 0, shop.ease_level * easefunc(shop.ease_timer / shop.ease_time) + shop.ease_target * (1 - easefunc(shop.ease_timer / shop.ease_time)), wx, wy)
  end
end

function easefunc(x)
  return x * x * x
end

function shop:open_menu(s)
  shop.open_shop = shop:shopize(s)
  shop.shop_target = s
end

function shop:shopize(s)
  local res = {}
  local shop_screen = {
      pos = {0, 0},
      size = {1, 0.5},
      engraving = 0.01,
      type = "box",
      col = {0.1, 0.15, 0.35, 0.8},
      contents = {
        {
          type = "button",
          pos = {0.75, 0.3},
          size = {0.25, 0.4},
          engraving = 0.01,
          override = "reroll",
          button = {cost = math.max(0, s.reroll_price + s.reroll_mod)}
        },
        {
          type = "holder",
          pos = {0, 0},
          size = {0.75, 1},
          engraving = 0.04,
          contents = {

          }
        }
      }
    }

  local testermenu = fill_left_side_of_screen
  testermenu.contents = {shop_screen}


  for i, j in ipairs(s.contents) do
    if j ~= -1 then

      local row = (i - 1) % 4
      local col = math.floor((i - 1) / 4)

      local off = shop_types[s.type].off or 0

      local ob = {}
      ob.type = "button"
      ob.pos = {0.25 * row, 0.1 + 0.5 * col + off}
      ob.size = {0.2, 0.3}
      ob.button = {}
      ob.id = i

      shop_create_funcs[s.type](ob, i, j)

      table.insert(testermenu.contents[1].contents[2].contents, ob)
    end
  end
  return testermenu
end

shop_buy_funcs = {
  connector = function(i, j)
    connector_ui:add_copy(j.element.button.connector_ui)
    game.money = game.money - j.element.button.cost
    play_sound("moneys")
    --table.remove(shop.shop_target.contents, j.element.id)
    shop.shop_target.contents[j.element.id] = -1
    shop:open_menu(shop.shop_target)

    shop.frozen_items[j.element.id] = nil
  end,
  fruit = function(i, j)
    fruit_spawner:add_to_deck(j.element.button.fruit)
    game.money = game.money - j.element.button.cost
    play_sound("moneys")
    --table.remove(shop.shop_target.contents, j.element.id)
    shop.shop_target.contents[j.element.id] = -1
    shop:open_menu(shop.shop_target)
  end,
  consumable = function(i, j)
    consumable:add(j.element.button.consumable)
    game.money = game.money - j.element.button.cost
    play_sound("moneys")

    shop.shop_target.contents[j.element.id] = -1
    shop:open_menu(shop.shop_target)
  end,
  reroll = function(i, j)
    shop.shop_target.reroll_mod = 0

    play_sound("moneys")
    game.money = game.money - j.element.button.cost

    shop.shop_target.reroll_price = shop.shop_target.reroll_price + 2
    shop.shop_target.contents = shop_types[shop.shop_target.type].populate()
    shop:open_menu(shop.shop_target)


  end
}

shop_rc_funcs = {
  connector = function(i, j)
    play_sound("ice")


    if shop.frozen_items[j.element.id] == nil then
      shop.frozen_items[j.element.id] = j.element
    else
      shop.frozen_items[j.element.id] = nil
    end
    j.element.frozen = (  shop.frozen_items[j.element.id] ~= nil)
  end
}

shop_create_funcs = {
  connector = function(ob, i, j)
    ob.button.connector_ui = j
    ob.button.cost = connector_types.list[j.connector.type].cost + #connector_ui.tiles
    if j.modified then
      ob.button.modified = true
      play_sound("whisk")
    end
  end,
  fruit = function(ob, i, j)
    ob.button.fruit = j
    ob.button.cost = 8
  end,
  consumable = function(ob, i, j)
    ob.button.consumable = j
    ob.button.cost = consumable_types[j.type].cost
  end,
}

shop_draw_funcs = {
  connector = function(j, x, y, sizex, sizey)
    if j.button.modified then
      --TODO: Make the sprite for this
      love.graphics.draw(sprites["connect_top_3"], x, y - 5, 0, 2)
    end

    connector_ui:drawone(j.button.connector_ui, x + sizex / 2, y + sizey / 2 - 5)

    love.graphics.setColor(1,1,1)

    if shop.frozen_items[j.id] ~= nil then
      love.graphics.setColor(0,1,1)
    end
    love.graphics.printf(j.button.cost .. "$", x, y + sizey, sizex, "center")
  end,
  fruit = function(j, x, y, sizex, sizey)
    fruit:draw_still(j.button.fruit, x + sizex / 2 + 25, y + sizey / 2 + 25, 60)

    love.graphics.setColor(1,1,1)
    love.graphics.printf(j.button.cost .. "$", x, y + sizey, sizex, "center")
  end,
  consumable = function(j, x, y, sizex, sizey)
    consumable:draw(j.button.consumable, x + sizex / 2 + 25, y + sizey / 2 + 25, 60)

    love.graphics.setColor(1,1,1)
    love.graphics.printf(j.button.cost .. "$", x, y + sizey, sizex, "center")
  end,
  reroll = function(j, x, y, sizex, sizey)
    love.graphics.printf("ROLL RE", x, y, sizex, "center")

    love.graphics.setColor(1,1,1)
    love.graphics.printf(j.button.cost .. "$", x, y + sizey, sizex, "center")
  end,
}

function shop:mouse(mx, my, mb)
  if not shop.open_shop then
    return
  end
  if shop.close then
    return
  end
  local buttons = smartmenu_find(shop.open_shop, 0,  shop.ease_level * shop.ease_timer * shop.ease_timer * shop.ease_timer * 5, wx, wy, 0, "button")
  for i, j in ipairs(buttons) do
    local button = j.element.button
    if col(j.x + j.sizex / 2, mx, j.y + j.sizey / 2, my, j.sizex / 2, j.sizey / 2) then
      if j.element.override == nil and mb == 2 then
        local tfunc = shop_rc_funcs[shop.shop_target.type] or function() end
        tfunc(i, j)
        return
      end
      if j.element.override == nil and button.cost <= game.money then

        shop_buy_funcs[shop.shop_target.type](i, j)
        return
      elseif j.element.override and (button.cost <= game.money or button.cost == nil) then
        shop_buy_funcs[j.element.override](i, j)
        return
      end
    end
  end
end
