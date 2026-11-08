connector_ui = {}
CXSIZE = 55
CYSIZE = 75

function connector_ui:init(startup)
  connector_ui.tiles = {}
  --[[
  connector_ui:add_tile("bananas")
  connector_ui:add_tile("droptheapple")
  connector_ui:add_tile("cherrypicking")
  connector_ui:add_tile("downgrade")
  connector_ui:add_tile("magnet")
  connector_ui:add_tile("onepoint")
  ]]
  --u
  --j
  connector_ui:add_tile("standstill")
  connector_ui:add_tile("snakeeyes")
  --connector_ui:add_tile("gforce")
    --[[
  connector_ui:add_tile("morepoints")
  connector_ui:add_tile("bananas")
  connector_ui:add_tile("bomber")
  connector_ui:add_tile("jumpup")
  connector_ui:add_tile("lastfifteen")
  connector_ui:add_tile("countdown")
  connector_ui:add_tile("evenmorepoints")
  connector_ui:add_tile("once")
  connector_ui:add_tile("cherry")
  connector_ui:add_tile("twice")
  connector_ui:add_tile("triplebogey")
  connector_ui:add_tile("highspawn")
  connector_ui:add_tile("magnet")
  connector_ui:add_tile("abundance")
  connector_ui:add_tile("fruited")
  connector_ui:add_tile("afewmore")
  connector_ui:add_tile("karma")
  connector_ui:add_tile("droptheapple")
  connector_ui:add_tile("debug")
  connector_ui:add_tile("shapeshift")
  connector_ui:add_tile("scatterbrain")
  connector_ui:add_tile("fruitbowl")
  connector_ui:add_tile("bump")
  connector_ui:add_tile("nothingleft")
  connector_ui:add_tile("citrus")
  ]]
end

function connector_ui:add_tile(connect_, dont_add)
  local connecty = connect_ or "jump"
  local ob = {}
  ob.x = wx * 5 / 6 + love.math.random(-90, 90)
  ob.y = wy / 2 + love.math.random(-240, 240)
  ob.vx = 0
  ob.vy = 0
  ob.drag = false
  ob.highlight = false
  ob.id = love.math.random(1,10)
  ob.layer = 0
  ob.connector = connectors:make(connecty)
  ob.pulse = 0
  ob.sprite = connector_ui:make_sprite(ob.connector)
  if dont_add then
    return ob
  end
  table.insert(connector_ui.tiles, ob)
end

function connector_ui:add_copy(connect)
  local connecty = connect_ or "jump"
  local ob = {}
  ob.x = wx * 5 / 6 + love.math.random(-90, 90)
  ob.y = wy / 2 + love.math.random(-240, 240)
  ob.vx = 0
  ob.vy = 0
  ob.drag = false
  ob.highlight = false
  ob.id = love.math.random(1,10)
  ob.layer = 0
  ob.connector = connect.connector
  ob.pulse = 0
  ob.sprite = connect.sprite
  table.insert(connector_ui.tiles, ob)
end

function connector_ui:make_sprite(j)
  --[[
  Stitch the top and bottom connector sprites together, then multiply the result by the connector sprite
  ]]

  local ctypeT, ctypeB = j.c_args[1] or 0, j.c_args[2] or 0
  local cspriteT, cspriteB
  if sprites["connect_top_" .. ctypeT] and sprites["connect_bottom_" .. ctypeB] then
    cspriteT = love.image.newImageData("sprites/connect_top_" .. ctypeT .. ".png") --sprites["connect_top_" .. ctypeT]
    cspriteB = love.image.newImageData("sprites/connect_bottom_" .. ctypeB .. ".png")
  else
    error("What? connector type " .. ctypeT .. " has missing sprites?")
  end

  local ctype = j.type
  local ccolor = connector_colors["connector/" .. j.type]
  local csprite

  if sprites["connector/" .. j.type] then
    csprite = love.image.newImageData("sprites/connector/" .. j.type .. ".png")
  else
    if ctypeT == 0 then
      csprite = love.image.newImageData("sprites/connector/test_if.png")
    elseif ctypeB == 0 then
      csprite = love.image.newImageData("sprites/connector/test_then.png")
    else
      csprite = love.image.newImageData("sprites/connector/test_ex.png")
    end
  end

  local theight = cspriteT:getHeight()
  local bheight = cspriteB:getHeight()
  local cwidth  = cspriteT:getWidth()

  local full_image = love.image.newImageData(cwidth, cspriteT:getHeight() + cspriteB:getHeight())

  for x = 0, cwidth - 1 do
    for y = 0, theight - 1 do
      local r,g,b,a = cspriteT:getPixel(x, y)
      if x < csprite:getWidth() then
        local cr, cg, cb, ca = csprite:getPixel(x, y)

        r, g, b, a = r * cr, g * cg, b * cb, a * ca
      end
      full_image:setPixel(x, y, r, g, b, a)
    end

    for y = 0, bheight - 1 do
      local r,g,b,a = cspriteB:getPixel(x, y)
      if x < csprite:getWidth() and (y + theight) < csprite:getHeight() then
        local cr, cg, cb, ca = csprite:getPixel(x, y + theight)

        r, g, b, a = r * cr, g * cg, b * cb, a * ca
      end
      full_image:setPixel(x, y + theight, r, g, b, a)
    end
  end

  return love.graphics.newImage(full_image)

end

function connector_ui:change_args(c, arg1, arg2)
  c.connector.c_args = {arg1, arg2}
  c.sprite = connector_ui:make_sprite(c.connector)
end

function connector_ui:draw()
  love.graphics.setColor(0.2, 0.2, 0.3)
  love.graphics.rectangle("fill", wx * 2 / 3, 0, wx , wy)

  for i, j in ipairs(connector_ui.tiles) do
    connector_ui:drawone(j, j.x, j.y)
  end
end



function connector_ui:drawone(j, x, y)
  --love.graphics.setColor(((j.connector.c_args[1] == nil) and 1) or 0,(j.connector.c_args[1] or 0) / 4,(j.connector.c_args[2] or 0) / 4)

  love.graphics.setColor(1,1,1)
  if j.highlight == 1 then
    love.graphics.setColor(1,1,0)
  end
  if j.highlight == -1 then
    love.graphics.setColor(0,1,1)
  end
  local sx, sy = CXSIZE, CYSIZE
  if (j.pulse ~= nil) and (j.pulse > 0) then
    sx = sx * (1 + j.pulse * 0.5)
    sy = sy * (1 + j.pulse * 0.5)
  end
  --love.graphics.rectangle("fill", j.x - sx / 2, j.y - sy / 2, sx, sy)

  --[[
  local ctypeT, ctypeB = j.connector.c_args[1] or 0, j.connector.c_args[2] or 0
  if sprites["connect_top_" .. ctypeT] and sprites["connect_bottom_" .. ctypeB] then
    love.graphics.draw(sprites["connect_top_" .. ctypeT], x - sx / 2, y - sy / 2, 0, sx / CXSIZE)
    love.graphics.draw(sprites["connect_bottom_" .. ctypeB], x - sx / 2, y - sy / 2 + 42, 0, sx / CXSIZE)

  end

  if sprites["connector/" .. j.connector.type] then
    love.graphics.setColor(1,1,1)
    love.graphics.draw(sprites["connector/" .. j.connector.type], x - sx / 2 + 2, y - sy / 2 + 10, 0, sx / CXSIZE)
  else

    love.graphics.setColor(0,0,0)
    love.graphics.print(j.connector.type, x , y)
  end

  ]]

  --love.graphics.setColor(1,1,1)
  love.graphics.draw(j.sprite, math.floor(x - sx / 2), math.floor(y - sy / 2), 0, sx / CXSIZE)
  love.graphics.setColor(0,0,0)
  love.graphics.setFont(font_lower)
  love.graphics.printf(j.connector.type, x , y - sy / 2, sx, "center")

  local mx, my = love.mouse.getX(), love.mouse.getY()
  if col(x, mx, y, my, CXSIZE / 2 + 5, CYSIZE / 2 + 10) then
    love.graphics.setColor(1,1,1)
    love.graphics.rectangle("fill", x + sx / 2 + 20, y - sy / 3, sx * 3, sy)
    love.graphics.setColor(0,0,0)
    love.graphics.printf(connector_types:get_desc(j), x + sx / 2 + 20, y - sy / 3, sx * 3, "center")
  end

  love.graphics.printf(connector_types:get_extra_info(j), x - sx / 2, y + sy / 3, sx, "center")
  love.graphics.setFont(font_low)

  if love.keyboard.isDown("7") then
    love.graphics.printf(j.connector.times_triggered, x - sx + 10, y + sy / 3, sx, "center")
    love.graphics.setFont(font_low)
  end

  if j.connector.stickers and #j.connector.stickers > 0 then
    love.graphics.printf(j.connector.times_triggered, x - sx + 10, y + sy / 3, sx, "center")
    love.graphics.setFont(font_low)
  end

  --[[
  if j.child then
    love.graphics.print("c" .. j.child.id, x + 10 , y + 10)
  end
  if j.parent then
    love.graphics.print("pa" .. j.parent.id, x + 10 , y - 10)
  end
  ]]
  if j.connector.perma_bonus and j.connector.perma_bonus ~= 0 then
    love.graphics.print("+" .. j.connector.perma_bonus, x + 10 , y + 10)
  end
end

function connector_ui:mouse(mx, my, mb)
  if mb == 2 then
    local dels = {}
    for i = #connector_ui.tiles, 1, -1 do
      local j = connector_ui.tiles[i]
      if col(j.x, mx, j.y, my, CXSIZE / 2 + 10, CYSIZE / 2 + 20) and j.parent == nil and j.child == nil then
        connectors:proc_all_when("sell", j)
        table.remove(connector_ui.tiles, i)
        game.money = game.money + 1
        break
      end
    end
  end
  if mb ~= 1 then
    return
  end

  for i = #connector_ui.tiles, 1, -1 do
    local j = connector_ui.tiles[i]
    if col(j.x, mx, j.y, my, CXSIZE / 2 + 10, CYSIZE / 2 + 20) then
      if not j.drag then
        play_sound("default")
        j.drag = true
        j.orig_mx = mx
        j.orig_my = my
        table.remove(connector_ui.tiles, i)
        table.insert(connector_ui.tiles, j)

        local c = j.child
        while c ~= nil do
          for a, b in ipairs(connector_ui.tiles) do
            if (b == c) then
              table.remove(connector_ui.tiles, a)
              table.insert(connector_ui.tiles, b)
              break
            end
          end
          c = c.child
        end


      else
        j.drag = false
      end
      break
    end
  end
end


function connector_ui:update(dt)
  local mx, my = love.mouse.getX(), love.mouse.getY()
  for i, j in ipairs(connector_ui.tiles) do
    j.highlight = 0
    j.collapsed = false
  end
  for i, j in ipairs(connector_ui.tiles) do
    if j.drag then
      -- when dragging, highlight nearby connectors
      for k, l in ipairs(connector_ui.tiles) do
        if j.parent == nil and l.child == nil and i ~= k and col(j.x, l.x, j.y - CYSIZE / 2 - 5, l.y, CXSIZE + 10, CYSIZE / 2 + 5)  and connectors:can_connect(l.connector, j.connector) then
          l.highlight = -1
          break
        end
      end
      if j.child == nil then
        for k, l in ipairs(connector_ui.tiles) do
          if l.parent == nil and j.child == nil and i ~= k and col(j.x, l.x, j.y + CYSIZE / 2, l.y, CXSIZE + 10, CYSIZE / 2 + 10)  and connectors:can_connect(j.connector, l.connector) then
            l.highlight = 1
            break
          end
        end
      else
        local fc = furthest_child(j)
        if jc ~= j and  fc ~= nil then
          for k, l in ipairs(connector_ui.tiles) do
            if l.parent == nil and fc.child == nil and i ~= k and col(fc.x, l.x, fc.y + CYSIZE / 2, l.y, CXSIZE + 10, CYSIZE / 2 + 10)  and connectors:can_connect(fc.connector, l.connector) then
              l.highlight = 1
              break
            end
            if fc.parent == nil and l.child == nil and i ~= k and col(fc.x, l.x, fc.y - CYSIZE / 2 - 5, l.y, CXSIZE + 10, CYSIZE / 2 + 5)  and connectors:can_connect(l.connector, fc.connector) then
              l.highlight = -1
              break
            end
          end
        end
      end


      if not love.mouse.isDown(1) then
        j.drag = false
        --when we stop dragging, attempt to connect to nearby connectors
        if j.child == nil then
          connector_ui:connect(j)
        else
          connector_ui:connect(j)
          local fc = furthest_child(j)
          if jc ~= j and  fc ~= nil then
            connector_ui:connect(fc, false, true)
          end
        end
      end


      j.vx = (mx - j.x) / 2
      j.vy = (my - j.y) / 2
    end

    if j.orig_mx and (math.abs(j.orig_mx - mx) > 2 or math.abs(j.orig_my - my) > 2) then
      --connector that either snapped off or is just a parent being dragged
      if j.parent ~= nil then
        j.parent.child = nil
        j.parent = nil

        play_sound("wood")
      end
      j.orig_mx = nil
      j.orig_my = nil
      j.drag = true


    end

    j.x = j.x + j.vx
    j.y = j.y + j.vy
    j.vx = j.vx * 0.6
    j.vy = j.vy * 0.6

    if j.pulse > 0 then
      j.pulse = j.pulse - dt
    end
  end
  for i, j in ipairs(connector_ui.tiles) do
    if not j.collapsed then
      connector_ui:collapse(j)
    end
  end

  if game.pause or game.state == "shop" then
    return
  end

  for i, j in ipairs(connector_ui.tiles) do
    if connector_types.list[j.connector.type].update ~= nil then
      connector_types.list[j.connector.type].update(j, dt)
    end
  end

end

function connector_ui:connect(j, no_up_, no_down_)
  local up = not no_up_
  local down = not no_down_
  for k, l in ipairs(connector_ui.tiles) do
    if l.parent == nil and j.child == nil and j ~= l and col(j.x, l.x, j.y + CYSIZE / 2, l.y, CXSIZE + 10, CYSIZE / 2 + 10) and (l.parent ~= j) and up and connectors:can_connect(j.connector, l.connector) then
      --UP connection, l is the child node
      if (j.child ~= nil) then
        j.child.parent = l
      end
      if (l.parent ~= nil) then
        l.parent.child = j
        j.parent = l.parent
      end
      j.child = l
      l.parent = j

      play_sound("snap")
      return
    end
    if j.parent == nil and l.child == nil and j ~= l and col(j.x, l.x, j.y - CYSIZE / 2 - 5, l.y, CXSIZE + 10, CYSIZE / 2 + 5) and (j.parent ~= l) and down and connectors:can_connect(l.connector, j.connector) then
      --DOWN connection, j is the child node
      if (l.child ~= nil) then
        l.child.parent = j
      end
      if (j.parent ~= nil) then
        j.parent.child = l
        l.parent = j.parent
      end
      l.child = j
      j.parent = l

      play_sound("snap")
      return
    end
  end
end

function connector_ui:collapse(j)
  if j.child == j then
    error("Self-child??????")
  end

  if j.child ~= nil then
    j.child.x = j.x
    j.child.y = j.y + CYSIZE + 4
    j.collapsed = true
    connector_ui:collapse(j.child)

  end
end

function furthest_child(j)
  if j.child == j then
    error("Self-child??????")
  end
  if j.child ~= nil then
    return furthest_child(j.child)
  end
  return j
end
