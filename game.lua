game = {}

font_high = love.graphics.newFont(32)
font_low  = love.graphics.newFont(16)

font_lower  = love.graphics.newFont(12)
font_xl   = love.graphics.newFont(48)

game_states = {
  main = {  --Main loop
    init = function()
      game:play()
      particle:init()
      game.pause = false
      menu_state = "main"
    end,
    draw = function()
      love.graphics.setBackgroundColor(0.3, 0.55, 0.9)
      love.graphics.push()

      love.graphics.translate(wx / 3, wy / 2)

      --[[
      love.graphics.translate(0, FLOOR - 25)
      love.graphics.scale(DEFAULT_SIZE / player.size,DEFAULT_SIZE / player.size)
      love.graphics.translate(0, -FLOOR - 25)
      ]]

      love.graphics.setColor(0.1, 0.4, 0.25)
      love.graphics.rectangle("fill", -wx / 3, FLOOR + 23, wx, wy)

      love.graphics.setColor(0.2, 0.5, 0.3)
      love.graphics.rectangle("fill", -wx / 3, FLOOR + 25, wx, wy)

      player:draw()
      spawns:draw()
      fruit:draw()
      particle:draw()

      love.graphics.pop()

      connector_ui:draw()
      love.graphics.setFont(font_xl)
      love.graphics.setColor(0.2,0.2,0.3)
      love.graphics.rectangle("fill", 50, 20 - 4, 150, 64)
      love.graphics.setColor(0.5,0.2,0.3)
      love.graphics.rectangle("fill", 50, 20 - 4, math.min(game.pts / game.requirement, 1) * 150, 64)
      love.graphics.setColor(1,1,1)
      local ptlength = 4. / math.max(4, #tostring(game.pts))
      love.graphics.printf(game.pts, 50, 20, 150 / ptlength, "center", 0, ptlength, 1)
      love.graphics.setFont(font_low)
      love.graphics.printf(game.requirement, 50, 84, 150, "center", 0, 1)
      love.graphics.printf(game.round, 50, 104, 150, "center", 0, 1)
      love.graphics.print(math.floor(game.timer), math.floor(wx / 4), 10)
      local nf = fruit_spawner.next_fruit
      local next_txt = ""
      if nf ~= nil then
        fruit:draw_still(nf, math.floor(wx / 2) - 35, 25, 30)
        if fruit_spawner.multi ~= 0 then
          love.graphics.print("x" .. (1 + fruit_spawner.multi), math.floor(wx / 2) - 20, 10)
        end
      end

      love.graphics.print(dbg or "", math.floor(wx / 2) - 70, 10)

      love.graphics.setColor(0.2,0.2,0.3)
      love.graphics.rectangle("fill", math.floor(wx / 2) - 50, 50 - 4, 40, 9)
      love.graphics.setColor(0.5,0.2,0.3)
      love.graphics.rectangle("fill", math.floor(wx / 2) - 50, 50 - 4, math.min((fruit_spawner.timer - fruit_spawner.max_timer) / (fruit_spawner.spawnrate - fruit_spawner.max_timer), 1) * 40, 9)

      love.graphics.setColor(1,1,1)
      love.graphics.print(next_txt, math.floor(wx / 2) - 50, 10)
      love.graphics.setFont(font_high)
      love.graphics.printf("$" .. game.money, math.floor(wx * 2 / 3) - 110, 30, 100, "right")
      love.graphics.setFont(font_low)

      consumable:draw_all(0, wy * 3/4)

      if love.keyboard.isDown("m") then
        game:draw_deck()
      end
    end,
    update = function(dt)
      if not game.pause then
        player:update(dt)

        local old_timer = math.floor(game.timer)
        game.timer = game.timer - dt

        if math.floor(game.timer) ~= old_timer then
          connectors:proc_all_when("timer")
          play_sound("tick")
          if game.timer <= 0 then
            game:lose()
          end
        end

        fruit_spawner:update(dt)

        fruit:update(dt)

        spawns:update(dt)
      end
      connector_ui:update(dt)
    end
  },
  menu = {
    init = function()
      particle:init()
      connector_ui:init()
    end,
    draw = function()

    end,
    update = function(dt)

    end
  },
  shop = {
    init = function()
      shop:init()
      spawns:init()
      fruit:init()
      player:init()
      fruit_spawner.next_fruit = nil

      player.x = -wx / 3.5

      table.insert(the_menu.contents, {
        type = "layout",
        pos = {0,0},
        size = {2/3, 1},
        contents = {{
        color = {0.2, 0.3, 0.7, 0.3, 0.5, 1},
        pos = {0.25, 0.75},
        size = {0.5, 0.25},
        engraving = 0.01,
        type = "button",
        button = {
          func = function()
            game:set_state("main")
            the_menu.contents = {}

          end,
          draw_func = function() end
        }
      }}})
    end,
    draw = function()
      love.graphics.setBackgroundColor(0.3, 0.55, 0.9)
      love.graphics.push()

      love.graphics.translate(wx / 3 - player.x, wy / 2)
      love.graphics.setColor(0.1, 0.4, 0.25)
      love.graphics.rectangle("fill", -wx / 3 + player.x, FLOOR + 23, wx, wy)

      love.graphics.setColor(0.2, 0.5, 0.3)
      love.graphics.rectangle("fill", -wx / 3 + player.x, FLOOR + 25, wx, wy)

      shop:draw()
      player:draw()

      love.graphics.pop()
      shop:draw_menu()
      connector_ui:draw()
      consumable:draw_all(0, wy * 3/4)

      love.graphics.setColor(1,1,1)

      love.graphics.setFont(font_high)
      love.graphics.printf("$" .. game.money, math.floor(wx * 2 / 3) - 110, 10, 100, "right")
      love.graphics.setFont(font_low)

      if love.keyboard.isDown("m") then
        game:draw_deck()
      end


    end,
    update = function(dt)
      player:update(dt)
      connector_ui:update(dt)
      shop:update(dt)
    end
  }


}

function game:set_state(st)
  game.state = st
  game:init()
end

BASE_GRAVITY = 1700
GRAVITY = BASE_GRAVITY
FLOOR = 150
DEFAULT_SPEED = 70

function game:init()
  local up = game_states[game.state].init
  if up then
    up(dt)
  end
end

function game:draw_deck()
  love.graphics.setColor(0.2, 0.2, 0.3)
  local psizex, psizey = 410, 270
  love.graphics.push()
  love.graphics.translate(wx / 3 - psizex / 2, wy / 3 - psizey / 4)

  love.graphics.rectangle("fill", 0, 0, psizex, psizey)
  for i, j in ipairs(game.deck) do
    local x, y = (i - 1) % 6, math.floor((i - 1) / 6.)
    love.graphics.setColor(0.3, 0.3, 0.4)
    fruit:draw_still(j, x * 60 + 60, y * 60 + 60, 60)
  end
  love.graphics.pop()
end

function game:setup_run(char)
  game.character = char
  game.money = 0
  game.deck = {}
  game.requirement = 25
  game.round = 1
  game.stands = {}
  consumable:init()
  psprite(char)

  playerdata[char].init()

  if false then

    for i = 1, 2 do

      for a = 1, 5 do
        fruit_spawner:add_to_deck(fruit_types:random())
      end

    end
  end
end


function game:play()
  player:init()
  fruit:init()
  spawns:init()
  for i, j in ipairs(connector_ui.tiles) do
    j.connector.times_triggered = 0
    if (connector_types.list[j.connector.type].start_round ~= nil) then
      connector_types.list[j.connector.type].start_round(j)
    end
  end
  GRAVITY = BASE_GRAVITY
  game.pts = 0
  game.timer = 60
  game.spawnrate = 1
  game.grape_bonus = 0

  local floor = math.floor((game.round - 1) / 3)
  local floor_round = (game.round - 1) % 3 + 1
  game.requirement = math.floor(20 * math.pow(1.4 + game.round / 70, floor) * math.pow(1.3 + game.round / 70, floor_round))
  fruit_spawner:init()
  fruit_spawner:choose_fruit()
  game.won = false
  game.lost = false
end

function game:draw()
  local up = game_states[game.state].draw
  if up then
    up(dt)
  end
end

function game:gain(pt)
  if pt < 0 and game.pts > 0 then
    queues:queue({func = function()
      connectors:proc_all_with_type("loser")
    end}, 0.05)
  end

  if pt == 1  then
    queues:queue({func = function()
      connectors:proc_all_with_type("getone")
    end}, 0.05)
  end

  game.pts = game.pts + pt
  if game.pts >= game.requirement then
    game:win()
  end

end

function game:win()
  if not game.won then
    game.pause = true
    local k = {
      type = "layout",
      pos = {0,0},
      size = {2/3, 1},
      contents = {
        {
          color = {0.2, 0.3, 0.7, 0.3, 0.5, 1},
          pos = {0.25, 0.75},
          size = {0.5, 0.25},
          engraving = 0.01,
          type = "button",
          button = {
            func = function()
              game.pause = false
              game.round = game.round + 1
              game.money = game.money + 10 + math.floor(game.timer / 5)
              the_menu.contents = {}
              game:set_state("shop")

              queues:clear()


            end,
            draw_func = function() end
          }
        }
      }
    }
    table.insert(the_menu.contents, k)
  end
  game.won = true
end

function game:lose()
  game.won = false
  if not game.lost then
    game.pause = true
    local k = {
      type = "layout",
      pos = {0,0},
      size = {2/3, 1},
      contents = {
        {
          color = {0.2, 0.3, 0.7, 0.3, 0.5, 1},
          pos = {0.25, 0.75},
          size = {0.5, 0.25},
          engraving = 0.01,
          type = "button",
          button = {
            func = function()
              game.pause = false
              game:set_state("menu")
              menu_init("menu")
              game:clear()
            end,
          }
        }
      }
    }

    table.insert(menu_buttons, k)
  end
  game.lost = true
end

function game:clear()
  game.money = 0
  game.round = 0

  game.grape_bonus = 0

  fruit:init(false)
  connector_ui:init(false)
  fruit_spawner:init(false)
  player:init(false)

end

function game:update(dt)

  local up = game_states[game.state].update
  if up then
    up(dt)
  end



end
