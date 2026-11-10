function love.load()
  love.window.setMode(1333,750,{resizable = true})
  wx, wy = love.window.getMode()

  require "menu"
  require "player"
  require "fruit_types"
  require "fruit"
  require "fruit_spawner"
  require "consumable"
  require "game"
  require "queues"
  require "particle"
  require "connector"
  require "connector_types"
  require "connector_ui"
  require "ui"
  require "shop"
  require "spawn"
  love.graphics.setDefaultFilter("nearest", "nearest", 1)

  a_hand = love.mouse.getSystemCursor("hand")
  cursor = "normal"

  sprites = {}
  connector_colors = {}
  for i, j in ipairs(love.filesystem.getDirectoryItems("sprites")) do
    if string.find(j, ".png") then
      sprites[string.sub(j,1,-5)] = love.graphics.newImage("sprites/" .. j)
    end
  end
  for i, j in ipairs(love.filesystem.getDirectoryItems("sprites/fruits")) do
    if string.find(j, ".png") then
      sprites["fruits/" .. string.sub(j,1,-5)] = love.graphics.newImage("sprites/fruits/" .. j)
    end
  end
  for i, j in ipairs(love.filesystem.getDirectoryItems("sprites/consumables")) do
    if string.find(j, ".png") then
      sprites["consumables/" .. string.sub(j,1,-5)] = love.graphics.newImage("sprites/consumables/" .. j)
    end
  end
  for i, j in ipairs(love.filesystem.getDirectoryItems("sprites/spawns")) do
    if string.find(j, ".png") then
      sprites["spawns/" .. string.sub(j,1,-5)] = love.graphics.newImage("sprites/spawns/" .. j)
    end
  end
  for i, j in ipairs(love.filesystem.getDirectoryItems("sprites/connector")) do
    sprites["connector/" .. string.sub(j,1,-5)] = love.graphics.newImage("sprites/connector/" .. j)
    local img = love.image.newImageData("sprites/connector/" .. j)
    local r,g,b,a = img:getPixel(0,0)
    connector_colors["connector/" .. string.sub(j,1,-5)] = {r,g,b}
  end

  sounds = {}
  for i, j in ipairs(love.filesystem.getDirectoryItems("sounds")) do
    sounds[string.sub(j,1,-5)] = love.audio.newSource("sounds/" .. j, "static")
  end
 --- fuir???????
  game:set_state("menu")
  game:init()

  menu_init("menu")
  smartmenu:init()

end

function play_sound(s, p_, v_)
  local p = p_ or 1
  local v = v_ or 1
  local q = sounds[s]
  q:setPitch(love.math.random(90, 110) / 100. * p)
  q:setVolume(v)
  love.audio.stop(q)
  love.audio.play(q)
end


function love.draw()

  setcursor = "normal"
  game:draw()
  menu()
  smartmenu:draw()

  if setcursor == "hand"  and love.mouse.getCursor() ~= a_hand then
    love.mouse.setCursor(a_hand)
    setcursor = ""
  elseif setcursor == "normal" and love.mouse.getCursor() ~= nil then
    love.mouse.setCursor()
    setcursor = ""
  end
end


function love.update(dt)
  if love.keyboard.isDown("lshift") then
    dt = dt * 3
  end
  if love.keyboard.isDown("rshift") then
    dt = dt * 0.28
  end
  game:update(dt)
  queues:update(dt)
  particle:update(dt)
  menu_update()
end

function love.mousepressed(mx, my, mb)
  connector_ui:mouse(mx, my, mb)
  shop:mouse(mx, my, mb)
  menu_press()
end

function love.keypressed(k)
  if k == "p" then
    game.pause = not game.pause
  end
  if k == "j" then
    connectors:proc_all_with_type("debug", player)
  end
  if k == "]" and love.keyboard.isDown("[") then
    game:gain(game.pts + 50)
    cheater = true
    game.money = (game.money + 10) * 2
  end
  if k == ";" then

    local exclusions = {}
    for a, b in ipairs(connector_ui.tiles) do
      exclusions[b.connector.type] = true
    end

    local b = shop:make_connector(exclusions)
    if b ~= nil then
      connector_ui:add_tile(b)
    end

  end

  if k == "g" then
    player.size = love.math.random(1, 150)
  end

  if k == "h" then
    psprite("hoarse")
  end
  if k == "y" then
    psprite("manguyperson")
  end

  if k == "q" then
    consumable:use_consumable(#consumable.owned)
  end
end
