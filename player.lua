player = {}

DEFAULT_SIZE = 50
function player:init()
  player.x = 0
  player.y = FLOOR
  player.vx = 0
  player.vy = 0
  player.dir = 1
  player.speed = DEFAULT_SPEED
  player.jump = 620
  player.c = 1
  player.size = DEFAULT_SIZE
  player.stun_timer = 0
  player.in_air = false

  player.anim_timer = 0
  player.sound_timer = 0
  player.squashx = 1
  player.squashy = 1
  player.skew = 0
  player.cycle = 0
end


playerdata = {
  hoarse = {
    sprites = {
      idle = "idlebasket.png",
      jump = "walk2basket.png",
      cycle = {"jumpbasket.png", "walk2basket.png"}
    },
    name = "Chor"
  },
  manguyperson = {
    sprites = {
      idle = "idlebasket.png",
      jump = "jumpbasket.png",
      cycle = {"jumpbasket.png"}
    },
    name = "Blue"
  }
}

function psprite(pname)
  local pdata = playerdata[pname].sprites
  player.s_idle = love.graphics.newImage("sprites/players/" .. pname .. "/" .. pdata.idle)
  player.s_jump = love.graphics.newImage("sprites/players/" .. pname .. "/" .. pdata.jump)
  player.s_walkcycle = {}
  for a, b in ipairs(pdata.cycle) do
    table.insert(player.s_walkcycle, love.graphics.newImage("sprites/players/" .. pname .. "/" .. b))
  end
end

psprite("manguyperson")

function player:draw()
  love.graphics.setColor(1,1,1)
  --love.graphics.rectangle("fill", player.x - player.size / 2, player.y - player.size + 25, player.size, player.size)
  local spr = player.s_idle
  if (player.anim_timer % 0.2 > 0.1) then
    spr = player.s_walkcycle[player.cycle % (#player.s_walkcycle) + 1]
  end
  if player.in_air then
    spr = player.s_jump
  end

  local pace = math.cos(love.timer.getTime() * 2) * 0.022
  if math.abs(player.vx) > 1 then
    pace = 0
  end
  player.squashx = player.squashx + (1 - player.squashx) / 3
  player.squashy = player.squashy + (1 + pace - player.squashy) / 3
  player.skew = player.skew * 0.8
  love.graphics.draw(spr, player.x, player.y + 25, 0, player.size / DEFAULT_SIZE * player.dir * player.squashx, (player.size / DEFAULT_SIZE) * player.squashy, 37, 110, player.skew, 0)
end

function key_inputs()
  return (love.keyboard.isDown("a") or love.keyboard.isDown("left")), love.keyboard.isDown("d") or love.keyboard.isDown("right"), love.keyboard.isDown("space")
end

function player:update(dt)
  local pspeed = player.speed
  if player.stun_timer > 0 then
    player.stun_timer = player.stun_timer - dt
    pspeed = pspeed / 7
  end
  local press_left, press_right, press_jump = key_inputs()

  if not (press_left or press_right) then
    player.anim_timer = 0
    player.sound_timer = 0
    player.cycle = 0
  else
    if player.anim_timer == 0 and not player.in_air then
      player.anim_timer = 0.11
      play_sound("tick", 0.2, 0.8)
    end
    player.anim_timer = player.anim_timer + dt
    if player.anim_timer > 0.2 then
      player.anim_timer = 0.01
      player.cycle = player.cycle + 1
    end
    if not player.in_air then
      player.sound_timer = player.sound_timer + dt
    end
    if player.sound_timer > 0.2 then
      player.sound_timer = 0
      play_sound("tick", 0.2, 0.8)
    end
    player.squashy = player.squashy - 1.6 * dt
    player.skew = player.skew - 1 * dt
  end

  if (press_left) then
    player.vx = player.vx - pspeed * dt * 60 * (player.size / DEFAULT_SIZE)
    player.dir = -1
  end
  if (press_right) then
    player.vx = player.vx + pspeed * dt * 60 * (player.size / DEFAULT_SIZE)
    player.dir = 1
  end
  player.j_timer = (player.j_timer or 0) - dt

  if (press_jump and  player.y > FLOOR - player.size / 5) and player.j_timer <= 0 then
    player:jump_upwards_instead_of_downwards()
    player.j_timer = 0.15
  end

  player.x = player.x + player.vx * dt
  player.y = player.y + player.vy * dt

  player.c = player.c - dt

  player.vx = player.vx * math.pow(0.8, 60*dt)
  if not (press_jump) then
    player.vy = player.vy + GRAVITY * dt * (player.size / DEFAULT_SIZE)
  end
  player.in_air = true

  if player.y > FLOOR then
    player.squashx = math.min(player.squashx + 0.5 / (player.size / DEFAULT_SIZE), 2)
    player.squashy = math.max(player.squashy - 0.4 / (player.size / DEFAULT_SIZE), 0.2)
  end

  if player.y >= FLOOR then
    player.y = FLOOR
    player.vy = 0
    player.in_air = false
  else
    player.vy = player.vy + GRAVITY * dt * (player.size / DEFAULT_SIZE)

    player.squashx = math.max(0.2, player.squashx - math.max(0, player.vy * dt / 90) / (player.size / DEFAULT_SIZE))
    player.squashy = player.squashy + math.max(0, player.vy * dt / 90) / (player.size / DEFAULT_SIZE)
    player.skew = 0
  end
  --   0.8 every 1/60 seconds
  --   dt is 1/30, sqrt(0.8)
  --   dt is 1/120, 0.8^2
  --   therefore, 0.8 ^ (60dt)
  --   we need to like. geometric mean ?????

  player:collide()
end

function player:jump_upwards_instead_of_downwards()
  player.c = 1
  player.vy = -player.jump  * (player.size / DEFAULT_SIZE)

  player.squashy = 0.7
  player.squashx = 1 / 0.7

  connectors:proc_all_with_type("jump", player)

  play_sound("default")
end

function player:collide()
  for i, j in ipairs(fruit.fruits) do
    if aabb(player.x + player.size / 2, j.x + j.size / 2, player.y + j.size / 2, j.y + j.size / 2, j.size, j.size, player.size, player.size  *1.5) then
      fruit:collect(i)
    end
  end

  if game.state == "shop" then
    local is_shopped = false
    for i, j in ipairs(shop.shops) do
      if aabb(player.x, j.x, player.y + player.size, j.y, player.size, player.size, j.sizex, j.sizey) then
        if shop.close then
          shop:open_menu(j)
          shop:ease()
        end
        shop.close = false
        is_shopped = true
      end
    end
    if not is_shopped then
      if not shop.close then
        shop:ease_out()
      end
      shop.close = true
    end
  end
end

function col(x1, x2, y1, y2, sz, _ysz)
  return ( math.abs(x1 - x2) <= sz and math.abs(y1 - y2) <= (_ysz or sz) )
end

function aabb(x1, x2, y1, y2, x1szx, x1szy, x2szx, x2szy)
  return (( x1 > x2 and x1 < x2 + x2szx ) or (x1 + x1szx > x2 and x1 + x1szx < x2 + x2szx)) and ((y1 > y2 and y1 < y2 + x2szy) or (y1 + x1szy > y2 and y1 + x1szy < y2 + x2szy))
end
