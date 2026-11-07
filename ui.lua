menus = {}

menus["main"] = {
  func = function()

  end
}

menus["menu"] = {
  func = function()
    --music = love.audio.newSource("sfx/world1theme.wav", "static")
    --music:setLooping(true)
    --music:play()
    --music:setVolume(0.3)
    table.insert(menu_buttons, {
      color = {0.2, 0.3, 0.7, 0.1, 0.1, 0.2},
      text = "START THE GAME",
      alttext = "",
      x = 500,
      y = wy - 130,
      sizex = 265,
      sizey = 65,
      func = function()
        game:setup_run()
        game:set_state("main")

      end,
      state = "menu",
    })
  end
}

menus["shop"] = {
  func = function()
    --music = love.audio.newSource("sfx/world1theme.wav", "static")
    --music:setLooping(true)
    --music:play()
    --music:setVolume(0.3)
    table.insert(menu_buttons, {
      color = {0.2, 0.3, 0.7, 0.1, 0.1, 0.2},
      text = "START THE GAME",
      alttext = "",
      x = wx / 3 - 132,
      y = wy * 3 / 4 + 33,
      sizex = 265,
      sizey = 65,
      func = function()
        game:set_state("main")
      end,
      state = "shop",
    })
  end
}



function menu()

    -- drawing the menu itself we have the Stolen From Baaba Code Because I'm TIRED OF BOX COLLISISON IMPLEMETNEFE FSOSUMSOEYESNS! !KHY!!

    for i, j in ipairs(menu_buttons) do

        if j.state == menu_state then
            if not j.hide then
            love.graphics.setColor(j.color[1], j.color[2], j.color[3])
            local jx, jy = j.x, j.y
            local jsizex, jsizey = j.sizex, j.sizey

            if j.justtext ~= true then
              if love.mouse.getX() > jx and love.mouse.getX() < jx + jsizex and  love.mouse.getY() > jy and love.mouse.getY() < jy + jsizey then
                if not love.mouse.isDown(1) then
                  love.graphics.setColor((j.color[1] + 1) / 2, (j.color[2] + 1) / 2, (j.color[3] + 1) / 2)
                else
                  love.graphics.setColor((j.color[1] + 0.6) / 2, (j.color[2] + 0.6) / 2, (j.color[3] + 0.6) / 2)
                end
              end
            end

            love.graphics.rectangle("fill", jx, jy, jsizex, jsizey)
            love.graphics.rectangle("line", jx, jy, jsizex, jsizey)

            if j.image ~= nil then
              love.graphics.setColor(1, 1, 1)
              love.graphics.draw(j.image, jx, jy, 0, j.sizex / j.image:getWidth())
              love.graphics.setBlendMode("alpha")
            end
            love.graphics.setColor(j.color[4], j.color[5], j.color[6])
            love.graphics.printf(j.text, jx, jy + jsizey / 2 - 8, jsizex, "center")
            love.graphics.setColor(1,1,1)
            love.graphics.setColor(0,0,0.5,0.5)
            --[[
            if j.rechargetimer ~= nil then
              love.graphics.rectangle("fill", jx, jy, jsizex, jsizey * j.rechargetimer / j.recharge)
            end
            ]]
          end

        end
    end
end

function menu_update(dt)
  for i, j in ipairs(menu_buttons) do

      if j.state == menu_state then
        if menus[menu_state].update ~= nil then
          menus[menu_state].update(j, i, dt)
        end
      end
  end
end


function menu_init(state)

  menu_buttons = {}


  menu_state = state
  menus[menu_state].func()


end

function can_press_button(j)
  return (j.rechargetimer == nil or j.rechargetimer <= 0)
end


function menu_press()


  for i, j in ipairs(menu_buttons) do
      if not j.hide and j.justtext ~= true and j.state == menu_state then
        local jx, jy = j.x, j.y
        local jsizex, jsizey = j.sizex, j.sizey
        local canpress = can_press_button(j)

        if canpress and love.mouse.getX() > jx and love.mouse.getX() < jx + jsizex and  love.mouse.getY() > jy and love.mouse.getY() < jy + jsizey then
            j.func(j, i)
        end
      end
  end

end
