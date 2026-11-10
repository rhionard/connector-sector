fruit = {}

function fruit:init(startup)
  fruit.fruits = {}
  fruit.timer = 0

  --VISUALS STUFF
  fruit.V_deadfruits = {}
end

function fruit:add(ft, x, y)
  if #fruit.fruits > 2000 then
    print("YOU BROKE THE GAME!")
    return
  end

  local ob = {}
  ob.fruit = ft
  ob.x = x
  ob.y = y or -wy
  ob.vx = 0
  ob.vy = 0
  ob.bonuses = {}

  fruit:setup(ob, ft, nil, true)

  table.insert(fruit.fruits, ob)
end

function fruit:draw()
  for i, j in ipairs(fruit.fruits) do
    fruit:drawone(j)
  end

  for i, j in ipairs(fruit.V_deadfruits) do
    fruit:drawone(j)
  end
end

function fruit:drawone(j)
  love.graphics.setColor(1,1,1)
  --love.graphics.setColor(fruit_types.list[j.fruit].color or {1,1,1})

  local layer = false
  local thedraw = false
  if j.bonuses["boosted"] then
    love.graphics.setColor(1,1,0,0.5)
    love.graphics.circle("fill", j.x, j.y, j.size)
    love.graphics.setColor(1,1,0)
  end
  if j.bonuses["bolded"] then
    love.graphics.setColor(1,0,0,0.5)
    love.graphics.circle("fill", j.x, j.y, j.size)
    love.graphics.setColor(1,1,0)
  end
  if fruit_types.list[j.fruit].draw then
    thedraw, layer = fruit_types.list[j.fruit].draw(j)
  end
  if not thedraw then
    love.graphics.draw(sprites["fruits/" .. j.fruit], j.x, j.y, j.x / 50 + j.y / 30, j.size / 30, j.size / 30, j.size / 2, j.size / 2)
  end
  if love.keyboard.isDown("7") then
    love.graphics.rectangle("line", j.x - j.size / 2, j.y - j.size / 2, j.size, j.size)
  end

  if layer then love.graphics.pop() end
end

function fruit:draw_still(j, x, y, jsize)
  local jfruit = j.fruit
  love.graphics.setColor(1,1,1)
  --love.graphics.setColor(fruit_types.list[j.fruit].color or {1,1,1})

  local layer = false

  if j.bonuses then
    if j.bonuses["boosted"] then
      love.graphics.setColor(1,1,0,0.5)
      love.graphics.circle("fill", x, y, jsize)
      love.graphics.setColor(1,1,0)
    end
    if j.bonuses["bolded"] then
      love.graphics.setColor(1,0,0,0.5)
      love.graphics.circle("fill", x, y, jsize)
      love.graphics.setColor(1,1,0)
    end
  end


  love.graphics.draw(sprites["fruits/" .. jfruit], x, y, 0, jsize / 30, jsize / 30, jsize / 2, jsize / 2)

  if layer then love.graphics.pop() end
end

function fruit:matches(ftype, fr)
  if type(ftype) == "table" then
    return ftype.fruit == fr
  end
  return ftype == fr
end

function fruit:update(dt)

  local dels = {}
  for i, j in ipairs(fruit.fruits) do

    j.y = j.y + j.speed * dt * GRAVITY / BASE_GRAVITY

    j.x = j.x + j.vx
    j.y = j.y + j.vy

    if j.bonuses["light"] then
      j.vy = j.vy - j.vy / 2
    end

    j.vx = j.vx * math.pow(0.8, 60*dt)
    j.vy = j.vy * math.pow(0.8, 60*dt)
    if fruit_types.list[j.fruit].update then
      fruit_types.list[j.fruit].update(j, dt)
    end

    if j.y > FLOOR + 150 then
      connectors:proc_all_when("miss", j)
      play_sound("thewondersofstaticelectricity")
      table.insert(dels, i)
    end
  end

  for a = #dels, 1, -1 do
    table.remove(fruit.fruits, dels[a])
  end



  dels = {}
  for i, j in ipairs(fruit.V_deadfruits) do

    j.size = j.size - 60 * dt
    j.life = j.life - dt

    if j.life <= 0 or j.size <= 0 then
      table.insert(dels, i)
    end

  end
  for a = #dels, 1, -1 do
    table.remove(fruit.V_deadfruits, dels[a])
  end
end

function fruit:spawn(dt)
  fruit_spawner:update(dt)
end

function fruit:transform(fr, target, no_init_, frame_one)
  fruit:setup(fr, target, no_init_, frame_one)
end

function fruit:setup(fr, target_deckfruit, no_init_, frame_one)
  if type(target_deckfruit) == "string" then
    error("Outdated system!!! Use the deck fruits instead!!")
  end
  local target = target_deckfruit.fruit
  fr.fruit = target
  local ftypelist = fruit_types.list[target]
  fr.size = ftypelist.size or 30
  fr.speed = ftypelist.speed or 120
  fr.bonuses = {}

  if target_deckfruit.bonuses then
    for i, j in pairs(target_deckfruit.bonuses) do
      fr.bonuses[i] = j
    end
  end

  if ftypelist.init and not (no_init) then
    ftypelist.init(fr, frame_one)
  end
end

function fruit:add_bonus(fr, bonus, extra)
  fr.bonuses[bonus] = extra or true
end

bonus_list = {"boosted", "bolded", "light"}
function fruit:random_bonus()
  return bonus_list[love.math.random(1, #bonus_list)]
end

function fruit:collect(fid, dont_remove_, dont_trigger_)
  local dont_remove_ = dont_remove_ or false
  local dont_trigger = dont_trigger_ or false

  local old_pts = game.pts

  if not dont_trigger then
    connectors:proc_all_when("collect", fruit.fruits[fid])
  end

  for i, j in ipairs(connector_ui.tiles) do
    if j.connector.type == "meteors" then
      j.connector.extra.val = 0
    end
  end

  local ftype = fruit.fruits[fid].fruit
  if fruit_types.list[ftype].collect then
    fruit_types.list[ftype].collect(fruit.fruits[fid])
  end

  if not dont_remove_ then

    table.insert(fruit.V_deadfruits, fruit.fruits[fid])
    fruit.V_deadfruits[#fruit.V_deadfruits].life = 1

  end

  local score_gain = fruit_types.list[ftype].score or 1

  if game.stands[ftype] then
    score_gain = score_gain + game.stands[ftype]
  end

  if fruit.fruits[fid].bonuses["bolded"] then
    score_gain = score_gain + 5
  end
  if fruit.fruits[fid].bonuses["boosted"] then
    score_gain = score_gain * 2
  end
  if fruit.fruits[fid].bonuses["cheesed"] then
    score_gain = score_gain - 1
  end

  game:gain(score_gain)

  local a = "pop"
  if game.pts - old_pts > 3 then
    a = "bigpop"
  end
  play_sound(a)

  if not dont_remove_ then
    table.remove(fruit.fruits, fid)
  end

end

function explosion(x, y)
  player.stun_timer = 3
  particle:add("boom", x or player.x, y or player.y)
  play_sound("kabloom")
  queues:queue({func = function()
    connectors:proc_all_when("explode")
  end}, 0.1)

end
