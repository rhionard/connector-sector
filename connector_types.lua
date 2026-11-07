COMMON = 1
UNCOMMON = 2
RARE = 3
LEGENDARY = 4
MYTHIC = 5

connector_types = {
  list = {
    --FINALLY!!!!

    --IFs
    jump = {
      rarity = COMMON,
      c_args = {nil,COMMON},
      cost = 6,
      check_when = "jump",
      start_round = function(c)
        c.connector.extra.count = 0
      end,
      func = function(c, args)
        c.connector.extra.count = (c.connector.extra.count or 0) + 1
        return c.connector.extra.count % 3 == 0
      end,
      desc = {
        "Triggers every 3rd %rjump%!"
      }
    },

    bananas = {
      rarity = UNCOMMON,
      c_args = {nil,UNCOMMON},
      cost = 7,
      check_when = "collect",
      func = function(c, args)
        return fruit:matches(args.fruit, "banana", args)
      end,
      desc = {
        "Triggers when you %ycollect%! a %yBanana"
      }
    },

    droptheapple = {
      rarity = UNCOMMON,
      c_args = {nil,UNCOMMON},
      cost = 6,
      check_when = "miss",
      func = function(c, args)
        return (fruit:matches(args.fruit, "apple", args))
      end,
      desc = {
        "Triggers when you %rmiss%! an %rApple"
      }
    },

    bombfruit = {
      rarity = UNCOMMON,
      c_args = {nil,UNCOMMON},
      cost = 6,
      check_when = "explode",
      desc = {
        "Triggers when a Bombfruit %rexplodes%!"
      }
    },

    fruited = {
      rarity = COMMON,
      c_args = {nil,COMMON},
      cost = 8,
      check_when = "collect",
      func = function(c, args)
        return fruit:matches(args.fruit, "apple") or fruit:matches(args.fruit, "banana") or fruit:matches(args.fruit, "watermelon")
      end,
      desc = {
        "Triggers when you %ycollect%! an",
        "%rApple%!, %yBanana%! or %gWatermelon%!"
      }
    },

    cycle = {
      rarity = COMMON,
      c_args = {nil,COMMON},
      cost = 3,
      check_when = "timer",
      func = function(c, args)
        return math.floor(game.timer) % 2 == 1
      end,
      desc = {
        "Triggers when the %btimer%!",
        "hits an odd number"
      }
    },

    loser = {
      rarity = COMMON,
      c_args = {nil,COMMON},
      cost = 5,
      desc = {
        "Triggers when you %rlose%! points,",
        "but still have points remaining"
      },

    },

    apple = {
      rarity = UNCOMMON,
      c_args = {nil,UNCOMMON},
      cost = 7,
      check_when = "collect",
      func = function(c, args)
        return fruit:matches(args.fruit, "apple")
      end,
      desc = {
        "Triggers when you %ycollect%! an %yApple"
      }
    },

    quintuplets = {
      rarity = RARE,
      c_args = {nil,RARE},
      cost = 7,
      check_when = "collect",
      start_round = function(c)
        c.connector.extra = {}
      end,
      func = function(c, args)
        c.connector.extra.count = c.connector.extra.count or 5
        if fruit:matches(args.fruit, "cherry") then
          c.connector.extra.count = c.connector.extra.count - 1
          if c.connector.extra.count <= 0 then
            c.connector.extra.count = 5
            return true
          end
        end
        return false
      end,
      extra_info = function(c)
        return {
          tostring(c.connector.extra.count or 0)
        }
      end,
      desc = {
        "Triggers every %y5th%! collected %rCherry%!"
      }
    },

    startup = {
      rarity = RARE,
      c_args = {nil,RARE},
      cost = 7,
      check_when = "timer",
      func = function(c, args)
        return math.floor(game.timer) == 57
      end,
      desc = {
        "Triggers when the %btimer%! hits 57",
      }
    },

    allonred = {
      rarity = RARE,
      c_args = {nil,RARE},
      cost = 7,
      check_when = "timer",
      func = function(c, args)
        return math.floor(game.timer) == 1 and love.math.random(1, 2) == 1
      end,
      desc = {
        "Triggers when the %btimer%! hits 1,",
        "with a 50% chance"
      }
    },

    downgrade = {
      rarity = UNCOMMON,
      c_args = {nil,UNCOMMON},
      cost = 4,
      desc = {
        "80% chance to trigger when a %yConnector%!",
        "activates another %yConnector%! of a lower %rrarity%!",
        "%I(EXAMPLE: An Uncommon trigger activating a Common trigger)"
      }
    },

    standstill = {
      rarity = UNCOMMON,
      c_args = {nil,UNCOMMON},
      cost = 3,
      start_round = function(c)
        c.connector.extra.val = 0
      end,
      update = function(c,  dt)
        c.connector.extra.val = (c.connector.extra.val or 0) + dt

        --do the check BEFORE to prevent being MEAN
        if c.connector.extra.val > 4 then
          connectors:proc(c)
          c.connector.extra.val = 0
          return
        end

        local pl, pr = key_inputs()

        if pl or pr then
          c.connector.extra.val = 0
        end

      end,
      extra_info = function(c)
        return {
          (math.floor(c.connector.extra.val or 0))
        }
      end,
      desc = {
        "Triggers if you don't move for 4 seconds",
      }
    },

    extension = {
      rarity = COMMON,
      c_args = {nil,COMMON},
      cost = 3,
      start_round = function(c)
        c.connector.extra.val = 100
      end,
      func = function(c)
        local res = love.math.random(0,99) < c.connector.extra.val
        if res then
          c.connector.extra.val = c.connector.extra.val * 0.95
        end
        return res
      end,
      extra_info = function(c)
        return {
          (math.floor(c.connector.extra.val or 0))
        }
      end,
      desc = {
        "%y100% chance%! to trigger when",
        "any %bExtender%! activates",
        "Chance multiplies by 95% each trigger"
      }
    },

    slipup = {
      rarity = COMMON,
      c_args = {nil,COMMON},
      cost = 3,
      check_when = "miss",
      func = function(c)
        return love.math.random(1,2) == 1
      end,
      desc = {
        "%y50% chance%! to trigger when",
        "you drop a fruit",
      }
    },

    spawnability = {
      rarity = COMMON,
      c_args = {nil,COMMON},
      cost = 6,
      check_when = "spawn",
      func = function(c, args)
        return fruit:matches(args.fruit, "grape") or fruit:matches(args.fruit, "grapes") --do later im tired i got 5 hours of sleep
      end,
      desc = {
        "Triggers when %pGrape%!(s) are",
        "%ospawned%! or %rdropped%!"
      }
    },

    temporalsavings = {
      rarity = RARE,
      c_args = {nil,RARE},
      cost = 9,
      check_when = "sell",
      func = function(c, args)
        return args.connector.rarity == UNCOMMON
      end,
      desc = {
        "Triggers when you %rsell%!",
        "an %gUncommon%! trigger",
      }
    },

    debug = {
      rarity = RARE,
      c_args = {nil,RARE},
      cost = 0,
      check_when = "debug"
    },



    --THENs
    onepoint = {
      rarity = COMMON,
      c_args = {COMMON, nil},
      cost = 3,
      func = function(c)
        game:gain(1)
      end,
      desc = {
        "%g+1 point"
      }
    },

    karma = {
      rarity = COMMON,
      c_args = {COMMON, nil},
      cost = 5,
      func = function(c)
        game:gain(3)
        player.size = player.size * 0.95
      end,
      desc = {
        "%g+3 points%!, but",
        "get 5% smaller"
      }
    },

    morepoints = {
      rarity = UNCOMMON,
      c_args = {UNCOMMON, nil},
      cost = 3,
      func = function(c)
        game:gain(7)
      end,
      desc = {
        "%g+7 points"
      }
    },

    evenmorepoints = {
      rarity = RARE,
      c_args = {RARE, nil},
      cost = 4,
      func = function(c)
        game:gain(40)
      end,
      desc = {
        "%g+40 points"
      }
    },

    topofthehill = {
      rarity = COMMON,
      c_args = {COMMON, nil},
      cost = 9,
      func = function(c)
        game:gain(7 - #connector_ui.tiles)
      end,
      get_desc = function(c)
        return {
          "%g+7 points%!, %r-1%! for",
          "each %yConnector%! you have"
        }
      end,
      extra_info = function(c)
        return {
          "+" .. (7 - #connector_ui.tiles)
        }
      end,
      desc = {
        "a"
      }
    },

    increment = {
      rarity = UNCOMMON,
      c_args = {UNCOMMON, nil},
      cost = 7,
      start_round = function(c)
        c.connector.extra = {}
      end,
      func = function(c)
        c.connector.extra.pts = (c.connector.extra.pts or 0) + 1
        game:gain(c.connector.extra.pts)
      end,
      extra_info = function(c)
        return {
          "+" .. (c.connector.extra.pts or 0)
        }
      end,
      desc = {
        "%g+1 point%! for each time",
        "this has been %ytriggered%! this round"
      }
    },

    seedling = {
      rarity = RARE,
      c_args = {RARE, nil},
      cost = 2,
      func = function(c)
        c.connector.perma_bonus = c.connector.perma_bonus + 10
        game:gain(10)
      end,
      desc = {
        "%g+10 points%!",
        "This %yConnector%! gains",
        "%g+10 permanent points%!"
      }
    },

    chumpchange = {
      rarity = RARE,
      c_args = {RARE, nil},
      cost = 5,
      func = function(c)
        if (game.money == 0) then
          game.money = game.money + 10
        end
      end,
      desc = {
        "If you have %y0$%!,",
        "Gain %y10$%!",
      }
    },

    beanstalk = {
      rarity = UNCOMMON,
      c_args = {UNCOMMON, nil},
      cost = 9,
      func = function(c)
        local cparent = c.parent
        while cparent do
          if love.math.random(1, 4) == 1 then
            cparent.connector.perma_bonus = cparent.connector.perma_bonus + 1
          end
          cparent = cparent.parent
        end
        game:gain(3)
      end,
      desc = {
        "%g+3 points%!",
        "Above %yConnectors%! have a %y25% chance%!",
        "to gain %g+1 permanent point%!"
      }
    },

    loselm = {
      rarity = UNCOMMON,
      c_args = {UNCOMMON, nil},
      cost = 9,
      func = function(c)
        game.timer = game.timer - 60
      end,
      desc = {
        "-60 seconds lm"
      }
    },

    magnet = {
      rarity = COMMON,
      c_args = {COMMON, nil},
      cost = 6,
      func = function(c)
        for i, j in ipairs(fruit.fruits) do
          j.vx = j.vx / 2 + (player.x - j.x) / 18
          j.vy = j.vy / 2 + (player.y - j.y) / 20
        end
      end,
      desc = {
        "Brings all onscreen fruits closer to you",
      }
    },

    bump = {
      rarity = COMMON,
      c_args = {COMMON, nil},
      cost = 6,
      func = function(c)
        for i, j in ipairs(fruit.fruits) do
          j.vy = (-wy - j.y) / 22
        end
      end,
      desc = {
        "Pushes all fruits upwards",
      }
    },

    throw = {
      rarity = COMMON,
      c_args = {COMMON, nil},
      cost = 3,
      func = function(c)
        for i, j in ipairs(fruit.fruits) do
          j.vy = (wy + j.y) / 16
        end
      end,
      desc = {
        "Pushes all fruits downwards",
      }
    },

    qol = {
      rarity = COMMON,
      c_args = {COMMON, nil},
      cost = 6,
      func = function(c)
        local rfruit = love.math.random(1, #fruit.fruits)
        if fruit.fruits[rfruit] ~= nil then
          fruit:add_bonus(fruit.fruits[rfruit], fruit:random_bonus())
        end
      end,
      desc = {
        "Adds a random %ybonus%!",
        "to a random onscreen fruit"
      }
    },

    shapeshift = {
      rarity = UNCOMMON,
      c_args = {UNCOMMON, nil},
      cost = 7,
      func = function(c)
        for i, j in ipairs(fruit.fruits) do
          fruit:transform(j, fruit_spawner.next_fruit)
        end
      end,
      desc = {
        "Turns all onscreen fruits into the %gupcoming%! fruit",
      }
    },

    scatterbrain = {
      rarity = COMMON,
      c_args = {COMMON, nil},
      cost = 3,
      func = function(c)
        for i, j in ipairs(fruit.fruits) do
          fruit:transform(j, {fruit = fruit_types:random()})
        end
      end,
      desc = {
        "Turns all onscreen fruits into random fruits",
      }
    },

    lotteryticket = {
      rarity = COMMON,
      c_args = {COMMON, nil},
      cost = 1,
      start_round = function(c)
        c.connector.extra.fruit = fruit_spawner:choose_from_deck()
      end,
      func = function(c)
        fruit_spawner.next_fruit = c.connector.extra.fruit
      end,
      extra_info = function(c)
        if c.connector.extra.fruit == nil then
          return {"none"}
        end

        return {
          "FRUIT",
          c.connector.extra.fruit.fruit
        }
      end,
      desc = {
        "Start of Round: Select a random fruit from deck",
        "During Round: Changes upcoming fruit to the selected fruit"
      }
    },

    teleport = {
      rarity = COMMON,
      c_args = {COMMON, nil},
      cost = 5,
      func = function(c)
        local x, y = love.mouse.getX() - wx / 3, love.mouse.getY() - FLOOR - 200
        player.x, player.y = x, y
      end,
      desc = {
        "Teleport to the mouse cursor"
      }
    },

    negation = {
      rarity = COMMON,
      c_args = {COMMON, nil},
      cost = 1,
      func = function(c)
        game:gain(-2 * game.pts)
      end,
      desc = {
        "%rx-1%! points"
      }
    },

    doubledup = {
      rarity = COMMON,
      c_args = {COMMON, nil},
      cost = 1,
      func = function(c)
        fruit_spawner.multi = fruit_spawner.multi + 1
        fruit_spawner:add_time(fruit_spawner.spawnrate)
      end,
      desc = {
        "+1 %gMultifruit%!",
        "The upcoming fruit takes",
        "1.5 more %ycycles%! to spawn"
      }
    },

    freeroll = {
      rarity = UNCOMMON,
      c_args = {UNCOMMON, nil},
      cost = 1,
      func = function(c)
        game.reroll_mod = (game.reroll_mod or 0) - 1
      end,
      desc = {
        "First reroll next shop costs 1$ less",
      }
    },

    abundance = {
      rarity = UNCOMMON,
      c_args = {UNCOMMON, nil},
      cost = 6,
      func = function(c)
        fruit_spawner:spawn()
        fruit_spawner.timer = 0
      end,
      desc = {
        "Spawns the next 2 %gupcoming%! fruits",
      }
    },

    composter = {
      rarity = UNCOMMON,
      c_args = {UNCOMMON, nil},
      cost = 3,
      func = function(c)
        for i = 0, love.math.random(0,6) do
          if i ~= 0 then
            fruit_spawner:spawn({fruit = fruit_types:random()}, true)
          end
        end
      end,
      desc = {
        "Spawns a random amount of random fruits",
      }
    },

    fruitbowl = {
      rarity = UNCOMMON,
      c_args = {UNCOMMON, nil},
      cost = 5,
      func = function(c)
        fruit_spawner:spawn({fruit = "apple"})
        fruit_spawner:spawn({fruit = "orange"})
        fruit_spawner:spawn({fruit = "cherry"})
      end,
      desc = {
        "Spawns an %rApple%!, %oOrange%! and %rCherry%!",
      }
    },

    afewmore = {
      rarity = UNCOMMON,
      c_args = {UNCOMMON, nil},
      cost = 5,
      start_round = function(c)
        c.connector.extra = {}
      end,
      func = function(c)
        c.connector.extra.uses = (c.connector.extra.uses or 0) + 1
        if (c.connector.extra.uses <= 8) then
          game.timer = game.timer + 3
        end
      end,
      extra_info = function(c)
        return {
          (c.connector.extra.uses or 0) .. "/8"
        }
      end,
      desc = {
        "+3 seconds on the %btimer%!",
        "8 uses"
      }
    },

    alotmore = {
      rarity = RARE,
      c_args = {RARE, nil},
      cost = 8,
      start_round = function(c)
        c.connector.extra = {}
      end,
      func = function(c)
        c.connector.extra.uses = (c.connector.extra.uses or 0) + 1
        if (c.connector.extra.uses <= 2) then
          game.timer = game.timer + 15
        end
      end,
      extra_info = function(c)
        return {
          (c.connector.extra.uses or 0) .. "/2"
        }
      end,
      desc = {
        "+15 seconds on the %btimer%!",
        "2 uses"
      }
    },

    highspawn = {
      rarity = RARE,
      c_args = {RARE, nil},
      cost = 6,
      func = function(c)
        fruit_spawner.spawnrate = fruit_spawner.spawnrate * 0.9
      end,
      desc = {
        "%g10%%! faster %gspawn rate%! for rest of round"
      }
    },

    jumpup = {
      rarity = COMMON,
      c_args = {COMMON, nil},
      cost = 2,
      func = function(c)
        queues:queue({func = function()
          player:jump_upwards_instead_of_downwards()
        end}, 0.1)
      end,
      desc = {
        "Makes you jump",
        "%i(even if you're not on the ground)"
      }
    },

    otang = {
      rarity = COMMON,
      c_args = {COMMON, nil},
      cost = 2,
      func = function(c)
        if love.math.random(1, 4) == 1 then
          fruit_spawner:spawn({fruit = "orange"})
        end
      end,
      desc = {
        "%y25% chance%! to spawn an %oOrange%!",
      }
    },

    bananerang = {
      rarity = COMMON,
      c_args = {COMMON, nil},
      cost = 4,
      func = function(c)
        if love.math.random(1, 8) == 1 then
          fruit_spawner:spawn({fruit = "banana"})
          fruit_spawner:spawn({fruit = "banana"})
        end
      end,
      desc = {
        "%y12.5% chance%! to spawn 2 %yBananas%!",
      }
    },

    cherrypicking = {
      rarity = UNCOMMON,
      c_args = {UNCOMMON, nil},
      cost = 3,
      func = function(c)
        local count = 0
        for i, j in ipairs(fruit.fruits) do
          if fruit:matches(j, "cherry") then
            count = count + 1
          end
        end
        game:gain(5 * count)
      end,
      extra_info = function(c)
        local count = 0
        for i, j in ipairs(fruit.fruits) do
          if fruit:matches(j, "cherry") then
            count = count + 1
          end
        end
        return {
          "+" .. (count * 5)
        }
      end,
      desc = {
        "%g+5 points for each",
        "%rCherry%! on screen"
      }
    },

    countdown = {
      rarity = COMMON,
      c_args = {COMMON, nil},
      cost = 3,
      start_round = function(c)
        c.connector.extra = {}
      end,
      func = function(c)
        c.connector.extra.timer = (c.connector.extra.timer or 11) - 1
        game.timer = c.connector.extra.timer
      end,
      extra_info = function(c)
        return {
          tostring(c.connector.extra.timer or 11)
        }
      end,
      desc = {
        "Sets %btimer%! to 11",
        "Decreases by 1 every use"
      }
    },

    citrus = {
      rarity = UNCOMMON,
      c_args = {UNCOMMON, nil},
      cost = 5,
      func = function(c)
        for i, j in ipairs(fruit.fruits) do
          if fruit:matches(args.fruit, "orange") then
            fruit:add_bonus(j, fruit:random_bonus())
          end
        end
      end,
      desc = {
        "Add a random %ybonus%! to",
        "all onscreen %oOranges%!"
      }
    },

    meteors = {
      rarity = UNCOMMON,
      c_args = {UNCOMMON, nil},
      cost = 8,
      start_round = function(c)
        c.connector.extra.val = 0
      end,
      func = function(c)
        game:gain(math.floor(c.connector.extra.val))
      end,
      update = function(c, dt)
        if c.connector.extra.val ~= nil and c.connector.extra.val >= 0 then
          c.connector.extra.val = c.connector.extra.val + dt
        end
      end,
      extra_info = function(c)
        return {
          tostring(math.floor(c.connector.extra.val or 0))
        }
      end,
      desc = {
        "%g+1 point%! for",
        "each second spent %rwithout%! collecting fruit"
      }
    },

    bigging = {
      rarity = UNCOMMON,
      c_args = {UNCOMMON, nil},
      cost = 5,
      func = function(c)
        player.size = player.size * 1.08
      end,
      desc = {
        "Get %g8% bigger%!",
      }
    },

    triplebogey = {
      rarity = RARE,
      c_args = {RARE, nil},
      cost = 7,
      start_round = function(c)
        c.connector.extra = {}
      end,
      func = function(c)
        c.connector.extra.uses = (c.connector.extra.uses or 0) + 1
        if (c.connector.extra.uses <= 3) then
          game:gain(math.floor(game.pts / 2))
        end
      end,
      extra_info = function(c)
        return {
          tostring((c.connector.extra.uses) or 0)
        }
      end,
      get_desc = function(c)
        return {
          "%gx1.5 points%! thrice",
          "%y" .. tostring(c.connector.extra.uses) .. "%!/3 uses"
        }
      end,
      desc = {
        "%gx1.5 points%! three times"
      }
    },

    big = {
      rarity = RARE,
      c_args = {RARE, nil},
      cost = 1,
      start_round = function(c)
        c.connector.extra = {}
      end,
      func = function(c)
        player.size = DEFAULT_SIZE * 5
      end,
      desc = {
        "get BIG"
      }
    },

    rna = {
      rarity = RARE,
      c_args = {RARE, nil},
      cost = 7,
      start_round = function(c)
        c.connector.extra = {}
      end,
      func = function(c)
        c.connector.extra.uses = (c.connector.extra.uses or 0) + 1
        if (c.connector.extra.uses == 1) then
          --TODO:   make a copier  instead of an appler
          fruit_spawner:add_to_deck({fruit = "apple"})
        end
      end,
      desc = {
        "Add a %ycopy%! of the gupcoming%! fruit",
        "to your deck %i(once per round)"
      }
    },

    agrape = {
      rarity = RARE,
      c_args = {RARE, nil},
      cost = 7,
      start_round = function(c)
        grape_bonus = 0
      end,
      func = function(c)
        fruit_spawner:spawn({fruit = "grape"})
        fruit_spawner:spawn({fruit = "grape"})
        grape_bonus = grape_bonus + 2
      end,
      desc = {
        "Spawns 2 %pGrapes%!",
        "%pGrape bushels%! spawn 2 additional %pGrape%!s"
      }
    },



    --CONNECTORS

    bomber = {
      rarity = COMMON,
      c_args = {COMMON, UNCOMMON},
      cost = 4,
      func = function(c)
        if fruit_spawner.next_fruit == nil then
          return false
        end
        return fruit:matches(fruit_spawner.next_fruit.fruit, "bombfruit")
      end,
      desc = {
        "Triggers if the %gupcoming%! fruit is a Bombfruit"
      }
    },

    lastfifteen = {
      rarity = COMMON,
      c_args = {COMMON, UNCOMMON},
      cost = 6,
      func = function(c)
        return (game.timer <= 10)
      end,
      desc = {
        "Triggers if the %btimer%!",
        "is %y10%! or less"
      }
    },

    kablooshk = {
      rarity = UNCOMMON,
      c_args = {UNCOMMON, UNCOMMON},
      cost = 1,
      start_round = function(c)
        c.connector.extra = {}
      end,
      func = function(c)
        c.connector.extra.val = (c.connector.extra.val or 0) + 1
        if (c.connector.extra.val % 2 == 1) then
          return
        end
        explosion()
      end,
      desc = {
        "Every other activation, %rExplode%!"
      }
    },

    once = {
      rarity = COMMON,
      c_args = {COMMON, RARE},
      cost = 5,
      start_round = function(c)
        c.connector.extra = {}
      end,
      func = function(c)
        local p = c.connector.extra.val
        c.connector.extra.val = false
        return (p == nil)

      end,
      desc = {
        "Triggers %yonce%! per round"
      }
    },

    twice = {
      rarity = UNCOMMON,
      c_args = {UNCOMMON, RARE},
      cost = 6,
      start_round = function(c)
        c.connector.extra = {}
      end,
      func = function(c)
        local p = c.connector.extra.val or 2
        c.connector.extra.val = p - 1
        return (p > 0)

      end,
      desc = {
        "Triggers %ytwice%! per round"
      }
    },

    cooldown = {
      rarity = UNCOMMON,
      c_args = {UNCOMMON, RARE},
      cost = 6,
      start_round = function(c)
        c.connector.extra = {}
      end,
      func = function(c)
        local p = c.connector.extra.val or 0
        if p <= 0 then
          c.connector.extra.val = 20
          return true
        end
        return false

      end,
      update = function(c, dt)
        if c.connector.extra.val ~= nil and c.connector.extra.val >= 0 then
          c.connector.extra.val = c.connector.extra.val - dt
        end
      end,
      desc = {
        "When triggered, cannot be triggered again for %y20%! seconds"
      }
    },

    dragdown = {
      rarity = UNCOMMON,
      c_args = {UNCOMMON, RARE},
      cost = 9,
      func = function(c)
        game:gain(1 - game.pts)

      end,
      desc = {
        "%rSet points to 1%! then trigger"
      }
    },

    zerograv = {
      rarity = UNCOMMON,
      c_args = {UNCOMMON, nil},
      cost = 4,
      func = function(c)
        GRAVITY = GRAVITY * 0.9
      end,
      desc = {
        "Decrease %ggravity%! by %y10%%!"
      }
    },

    gforce = {
      rarity = COMMON,
      c_args = {COMMON, nil},
      cost = 3,
      func = function(c)
        GRAVITY = GRAVITY * 1.05

      end,
      desc = {
        "Increase %ggravity%! by %y10%%!"
      }
    },

    nothingleft = {
      rarity = UNCOMMON,
      c_args = {UNCOMMON, RARE},
      cost = 6,
      func = function(c)
        return game.pts == 0
      end,
      desc = {
        "Triggers if you have %y0%! %gpoints%!"
      }
    },

    doubletime = {
      rarity = UNCOMMON,
      c_args = {UNCOMMON, COMMON},
      cost = 3,
      func = function(c)
        if c.child == nil then
          return
        end
        connectors:proc(c.child)
        connectors:proc(c.child)
      end,
      desc = {
        "Retrigger the %yConnector%! below this %ytwice%!"
      }
    },

    tripletimer = {
      rarity = RARE,
      c_args = {RARE, UNCOMMON},
      cost = 3,
      func = function(c)
        if c.child == nil then
          return
        end
        connectors:proc(c.child)
        connectors:proc(c.child)
      end,
      desc = {
        "Retrigger the %yConnector%! below this %ytwice%!"
      }
    },

    thrice = {
      rarity = COMMON,
      c_args = {COMMON, UNCOMMON},
      cost = 3,
      start_round = function(c)
        c.connector.extra = {}
      end,
      func = function(c)
        local p = c.connector.extra.val or 3
        c.connector.extra.val = p - 1
        return (p > 0)

      end,
      desc = {
        "Triggers %ythree times%! per round"
      }
    },

    appled = {
      rarity = COMMON,
      c_args = {COMMON, UNCOMMON},
      cost = 5,
      func = function(c)
        local count = 0
        for i, j in ipairs(fruit.fruits) do
          if fruit:matches(j.fruit, "apple", j) then
            count = count + 1
          end
        end
        if count >= 4 then
          return true
        end
        return false
      end,
      desc = {
        "Triggers if there are at least",
        "%y4%! %rApples%! on screen"
      }
    },

    huh = {
      rarity = COMMON,
      c_args = {COMMON, COMMON},
      cost = 1,
      desc = {
        "Always triggers, does nothing else"
      }
    },

    next_up = {
      rarity = UNCOMMON,
      c_args = {UNCOMMON, UNCOMMON},
      cost = 3,
      func = function(c, args)
        game:gain(4)
      end,
      desc = {
        "%g+4 points%! then triggers"
      }
    },

    seasontwo = {
      rarity = RARE,
      c_args = {RARE, RARE},
      cost = 3,
      func = function(c, args)
        game:gain(20)
      end,
      desc = {
        "%g+20 points%! then triggers"
      }
    },

    lol = {
      rarity = COMMON,
      c_args = {nil, nil},
      cost = 1,
      desc = {
        "lol"
      }
    },

  }
}

rarity_weights = {
  [COMMON] = 35,
  [UNCOMMON] = 15,
  [RARE] = 7,
  [LEGENDARY] = 1
}

flares = {"%%r", "%%g", "%%b", "%%p", "%%i", "%%!", "%%o", "%%y"}

function connector_types:get_desc(c)
  local txt = connector_types.list[c.connector.type].desc or connector_types.list["lol"].desc
  if connector_types.list[c.connector.type].get_desc then
    txt = connector_types.list[c.connector.type].get_desc(c)
  end

  local q = ""
  for a, b in ipairs(txt) do
    q = q .. b .. "\n"
  end

  for a, b in ipairs(flares) do
    q = string.gsub(q, b, "")
  end

  return q
end

function connector_types:get_extra_info(c)

  if connector_types.list[c.connector.type].extra_info then
    txt = connector_types.list[c.connector.type].extra_info(c)
  else
    return ""
  end

  local q = ""
  for a, b in ipairs(txt) do
    q = q .. b .. "\n"
  end

  return q
end

function connector_types:get_weight(rare)
  return rarity_weights[rare]
end
