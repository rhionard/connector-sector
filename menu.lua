--[[

NOT THE SAME AS UI. This is for the creation of menus like the shop menus and trading menus.

These need to be creatable at runtime, dnynamically updated, and also be properly aligned to any elements on screen.

I did something like this with my window project, having menus be a recursive function and having different ui element types.

That may not be the BEST solution, but i l ike it, so i'm probably going to do it here too.

Quick test for what a menu would look like:

fill_left_side_of_screen = {
  {
    type = "layout",
    pos = {0,0},
    size = {2/3, 1}
  }
}

shop_screen = {
  {
    type = "layout",
    pos = {0.05, 0.1},
    size = {0.9, 0.3}
    contents = {
      {
        type = "button",
        pos = {0.75, 0.8},
        size = {0.25, 0.1}
        contents = (reroll button)
      }
    }
  }
}

making the shop ui would out shop_screen in the contents of fill_left_side_of_screen occasionally



]]

fill_left_side_of_screen = {
  type = "layout",
  pos = {0,0},
  size = {2/3, 1}
}

shop_screen = {
    type = "layout",
    pos = {0, 0},
    size = {1, 0.5},
    engraving = 0.01,
    type = "test",
    contents = {
      {
        type = "button",
        pos = {0.75, 0.3},
        size = {0.25, 0.4},
        engraving = 0.01
      }
    }
  }

smartmenu_types = {
  test = {
    draw = function(sm, x, y, width, height, depth)
      love.graphics.setColor(0.5, 0.5, 0.6, 0.2)
      love.graphics.rectangle("fill", x, y, width, height)
      love.graphics.setColor(1,1,1)
      love.graphics.print(depth, x, y)
    end
  },
  box = {
    draw = function(sm, x, y, width, height, depth)
      local col = sm.col or {0.4, 0.5, 0.6, 0.2}
      love.graphics.setColor(col[1], col[2], col[3], col[4])
      love.graphics.rectangle("fill", x, y, width, height)
      love.graphics.setColor(1,1,1)
    end
  },
  button = {
    draw = function(sm, x, y, width, height, depth)
      local mx, my = love.mouse.getX(), love.mouse.getY()
      love.graphics.setColor(0.4, 0.5, 0.7, 0.4)
      if col(x + width / 2, mx, y + height / 2, my, width / 2, height / 2) then
        love.graphics.setColor(0.2, 0.3, 0.45, 0.4)
        setcursor = "hand"
      end
      love.graphics.rectangle("fill", x, y, width, height)
      love.graphics.setColor(1,1,1)
      if sm.button and sm.button.draw_func then
        sm.button.draw_func(sm, x, y, width, height)
        return
      end
      shop_draw_funcs[sm.override or shop.shop_target.type](sm, x, y, width, height)
    end
  },
  shoplist = {
    arrange = function(sm, id, el, x, y, width, height, depth)
      smartmenu_drawone(el, 0.1 + 0.1 * id, y, width, height, depth + 1)
    end
  }
}

smartmenu = {}

function smartmenu:init()
  smartmenu.menu = {}

  local testermenu = fill_left_side_of_screen
  testermenu.contents = {shop_screen}

  --smartmenu:add(testermenu)
end

function smartmenu:add(sm)
  table.insert(smartmenu.menu, sm)
  return sm
end

function smartmenu:draw()
  for i, j in ipairs(smartmenu.menu) do
    smartmenu_drawone(j, 0, 0, wx, wy)
  end
end

function smartmenu_drawone(sm, xstart, ystart, wid, hei, depth_, rettype_)
  local depth = depth_ or 0
  if not sm.pos then
    return
  end

  local engraving = sm.engraving or 0

  local x, y = xstart + (sm.pos[1] + engraving) * wid, ystart + (sm.pos[2] + engraving) * hei
  local width, height = (sm.size[1] - engraving * 2) * wid, (sm.size[2] - engraving * 2) * hei

  -- draw stuff

  if rettype_ == nil and (sm.type and smartmenu_types[sm.type] and smartmenu_types[sm.type].draw) then
    smartmenu_types[sm.type].draw(sm, x, y, width, height, depth)
  end

  if sm.contents then
    for a, b in ipairs(sm.contents) do
      if sm.type and smartmenu_types[sm.type] and smartmenu_types[sm.type].arrange then
        smartmenu_types[sm.type].arrange(sm, a, b, x, y, width, height, depth, rettype_)
      else
        smartmenu_drawone(b, x, y, width, height, depth + 1, rettype_)
      end

    end
  end

  return
end

function smartmenu_find(sm, xstart, ystart, wid, hei, depth_, rettype_)
  local depth = depth_ or 0
  local res = {}
  if not sm.pos then
    return res
  end
  local engraving = sm.engraving or 0

  local x, y = xstart + (sm.pos[1] + engraving) * wid, ystart + (sm.pos[2] + engraving) * hei
  local width, height = (sm.size[1] - engraving * 2) * wid, (sm.size[2] - engraving * 2) * hei

  if sm.type == rettype_ then
    table.insert(res, {element = sm, x = x, y = y, sizex = width, sizey = height})
  end

  if sm.contents then
    for a, b in ipairs(sm.contents) do
      if sm.type and smartmenu_types[sm.type] and smartmenu_types[sm.type].arrange then
        local subres = smartmenu_types[sm.type].arrange(sm, a, b, x, y, width, height, depth, rettype_)
        for a, b in ipairs(subres) do
          table.insert(res, b)
        end
      else
        local subres = smartmenu_find(b, x, y, width, height, depth + 1, rettype_)
        for a, b in ipairs(subres) do
          table.insert(res, b)
        end
      end

    end
  end

  return res
end


function smartmenu:mouse(themenu, mx, my, mb)
  local buttons = smartmenu_find(themenu, 0,  0, wx, wy, 0, "button")
  for i, j in ipairs(buttons) do
    local button = j.element.button
    if col(j.x + j.sizex / 2, mx, j.y + j.sizey / 2, my, j.sizex / 2, j.sizey / 2) then
      local tfunc = button.func or function() end
      tfunc(i, j)
      return
    end
  end
end
