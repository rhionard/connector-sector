spawns = {}

spawn_types = {
  fork = {
    flying = true,
    sizex = 30,
    sizey = 10,
    init = function(s)
      s.dir = love.math.random(-math.pi * 2/3 * 100, -math.pi / 3 * 100) / 100.
      s.vx = 600 * math.cos(s.dir)
      s.vy = 600 * math.sin(s.dir)
    end,
    update = function(s, dt)
      for a = #fruit.fruits, 1, -1 do
        local b = fruit.fruits[a]
        if aabb(b.x, s.x, b.y, s.y, b.size, b.size, s.sizex, s.sizey) then
          fruit:collect(a, true, true)
          fruit:collect(a)
        end
      end

    end,

  }
}

function spawns:init()
  spawns.list = {}
end

function spawns:spawn(stype, x, y)
  local ob = {}
  ob.x = x
  ob.y = y
  ob.vx = 0
  ob.vy = 0
  ob.sizex = spawn_types[stype].sizex or 50
  ob.sizey = spawn_types[stype].sizey or 50
  ob.type = stype
  ob.lifespan = spawn_types[stype].lifespan or 1
  ob.life = 0
  ob.dir = 0
  if spawn_types[stype].init then
    spawn_types[stype].init(ob)
  end
  table.insert(spawns.list, ob)
end

function spawns:draw()
  for i, j in ipairs(spawns.list) do
    love.graphics.push()

    love.graphics.translate(j.x, j.y)
    love.graphics.rotate(j.dir)

    love.graphics.rectangle("fill", - j.sizex / 2, - j.sizey / 2, j.sizex, j.sizey)
    love.graphics.pop()
  end
end

function spawns:update(dt)
  local dels = {}
  for i, j in ipairs(spawns.list) do
    local del = false
    if spawn_types[j.type].update then
      del = spawn_types[j.type].update(j, dt)
    end
    j.x = j.x + j.vx * dt
    j.y = j.y + j.vy * dt
    j.lifespan = j.lifespan - dt
    if j.lifespan <= 0 or del then
      table.insert(dels, i)
    end
  end
  for a = #dels, 1, -1 do
    table.remove(spawns.list, dels[a])
  end
end
