particle = {}

function particle:init()
  particle.list = {}
end

function particle:add(ptype, x, y)
  local ob = {}
  ob.x = x
  ob.y = y
  ob.size = 80
  ob.type = ptype
  ob.life = 1
  table.insert(particle.list, ob)
end

function particle:draw()
  for i, j in ipairs(particle.list) do
    love.graphics.setColor(1,0,0,j.life)
    local size = j.size
    size = size * (math.exp(-4 * ((1 - j.life) - 0.2) * ((1 - j.life) - 0.2)))
    love.graphics.rectangle("fill", j.x - size / 2, j.y - size / 2, size, size)
  end
end

function particle:update(dt)
  local dels = {}
  for i, j in ipairs(particle.list) do
    j.life = j.life - dt
    if j.life <= 0 then
      table.insert(dels, i)
    end
  end
  for a = #dels, 1, -1 do
    table.remove(particle.list, dels[a])
  end
end
