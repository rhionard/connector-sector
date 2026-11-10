fruit_types = {
  list = {
    apple = {
      color = {1,0,0},
      speed = 120
    },
    orange = {
      color = {1,0.8,0},
      speed = 165,
      cost = 7
    },
    watermelon = {
      color = {0,1,0},
      size = 35,
      speed = 180,
      score = 2
    },
    cherry = {
      color = {1,0,0.4},
      size = 25,
      speed = 70,
      cost = 10
    },
    bombfruit = {
      color = {0.3,0.3,0.3},
      size = 35,
      speed = 280,
      collect = function(fr)
        explosion(fr.x, fr.y)
        --[[
        player.speed = player.speed / 7
        queues:queue({
          func = function(l)
            player.speed = player.speed * 2
          end
        }, 3)
        ]]
      end,
      cost = 6
    },
    banana = {
      color = {1,1,0.4},
      size = 28,
      speed = 140,
      score = 2,
      init = function(fr, frame_one)
        if frame_one then
          fr.x = 0
        end
        fr.rand = (fr.rand or love.math.random(1, 19128))
        fr.timer = 0
      end,
      update = function(fr, dt)
        fr.timer = (fr.timer or 0) + dt
        fr.x = fr.x + 400 * math.cos(fr.timer * 2.2 + fr.rand) * dt
      end,
      draw = function(j)
        love.graphics.draw(sprites["fruits/" .. j.fruit], j.x, j.y, j.timer * 3, j.size / 30, j.size / 30, j.size / 2, j.size / 2)
        return true, false
      end
    },
    grapes = {
      size = 30,
      speed = 90,
      score = 1,
      collect = function(fr)
        for a = 1, (3 + (game.grape_bonus or 0)) do
          fruit:add({fruit = "grape"}, love.math.random(-wx / 4, wx / 4))
        end
      end,
      cost = 7
    },
    blueberries = {
      size = 25,
      speed = 200,
      score = 3,
      draw = function(j)
        love.graphics.draw(sprites["fruits/" .. j.fruit], j.x, j.y, j.y / 200, j.size / 20, j.size / 20, j.size / 2, j.size / 2)
        return true, false
      end
    },
    grape = {
      size = 25,
      speed = 90,
      score = 1,
      nospawn = true,
      init = function(fr)
        fr.speed = love.math.random(150, 240)
      end,
      draw = function(j)
        love.graphics.draw(sprites["fruits/" .. j.fruit], j.x, j.y, 0, j.size / 20, j.size / 20, j.size / 2, j.size / 2)
        return true, false
      end
    },
  }


}




function fruit_types:random()
  local q = {}
  for a, b in pairs(fruit_types.list) do
    if not b.nospawn then
      table.insert(q, a)
    end
  end
  return q[love.math.random(1, #q)]
end
