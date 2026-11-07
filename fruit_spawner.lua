--[[

fruit spawner + fruit deck
]]

fruit_spawner = {}

function fruit_spawner:init()
  fruit_spawner.timer = 0
  fruit_spawner.spawnrate = game.spawnrate
  fruit_spawner.max_timer = 0
  fruit_spawner.next_fruit = fruit_spawner:choose_from_deck()
  fruit_spawner.multi = 0
end

function fruit_spawner:add_to_deck(fr, extra_)
  if type(fr) == "table" then
    table.insert(game.deck, fr)
    return
  end

  local ob = {}
  ob.fruit = fr
  ob.bonuses = {}
  for a, b in pairs(extra_ or {}) do
    ob.bonuses[a] = b
  end
  table.insert(game.deck, ob)
end

function fruit_spawner:choose_fruit()
  fruit_spawner.next_fruit = fruit_spawner:choose_from_deck()--{fruit = fruit_types:random()}
end

function fruit_spawner:choose_from_deck()
  return game.deck[math.random(1, #game.deck)]
end

function fruit_spawner:spawn(fr, unoverride_, multi_)
  local count = (multi_ or 0) + 1
  local unoverride = unoverride_ or false

  for a = 1, math.min(count, 99) do
    fruit:add(fr or fruit_spawner.next_fruit, love.math.random(-wx / 3.5, wx / 3.5))
  end

  if not unoverride then
    fruit_spawner.next_fruit = fruit_spawner.next_fruit or fruit_spawner:choose_from_deck()
  end
end

function fruit_spawner:update(dt)
  fruit_spawner.timer = fruit_spawner.timer + dt

  if fruit_spawner.timer > fruit_spawner.spawnrate then

    fruit_spawner:spawn(nil, nil, fruit_spawner.multi)
    fruit_spawner.multi = 0
    fruit_spawner:choose_fruit()
    fruit_spawner.timer = 0
    fruit_spawner.max_timer = 0
  end
end

function fruit_spawner:add_time(t)
  fruit_spawner.timer = fruit_spawner.timer - t
  fruit_spawner.max_timer = math.min(fruit_spawner.max_timer, fruit_spawner.timer)
end
