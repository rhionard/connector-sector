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
      func = function(c, args, forced_)
        return therandomize(1,4)
      end,
      desc = {
        "Triggers when you Jump",
        "with a 25% chance"
      },
      name = "Jumper",
      pool = "default"
    },

    bananas = {
      rarity = UNCOMMON,
      c_args = {nil,UNCOMMON},
      cost = 7,
      check_when = "collect",
      func = function(c, args)
        return fruit:matches(args, "banana", args)
      end,
      desc = {
        "Triggers when you %ycollect%! a %yBanana"
      },
      name = "Banana Trigger",
      pool = "default"
    },

    droptheapple = {
      rarity = UNCOMMON,
      c_args = {nil,UNCOMMON},
      cost = 6,
      check_when = "miss",
      func = function(c, args)
        return (fruit:matches(args, "apple", args))
      end,
      desc = {
        "Triggers when you %rmiss%! an %rApple"
      },
      name = "Apple Slice",
      pool = "default"
    },

    bombfruit = {
      rarity = UNCOMMON,
      c_args = {nil,UNCOMMON},
      cost = 6,
      check_when = "explode",
      desc = {
        "Triggers when a Bombfruit %rexplodes%!"
      },
      name = "Catastrophic Failure",
      pool = "default"
    },

    fruited = {
      rarity = COMMON,
      c_args = {nil,COMMON},
      cost = 8,
      check_when = "collect",
      func = function(c, args)
        return fruit:matches(args, "apple") or fruit:matches(args, "banana") or fruit:matches(args, "watermelon")
      end,
      desc = {
        "Triggers when you %ycollect%! an",
        "%rApple%!, %yBanana%! or %gWatermelon%!"
      },
      name = "Traffic Lights",
      pool = "default"
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
      },
      name = "Cyclic Nature",
      pool = "default"
    },

    loser = {
      rarity = COMMON,
      c_args = {nil,COMMON},
      cost = 5,
      desc = {
        "Triggers when you %rlose%! points,",
        "but still have points remaining"
      },
      name = "You Lose!",
      pool = "default"
    },

    quintuplets = {
      rarity = RARE,
      c_args = {nil,RARE},
      cost = 7,
      check_when = "collect",
      start_round = function(c)
        c.connector.extra = {}
      end,
      func = function(c, args, forced_)
        if forced_ then
          return true
        end
        c.connector.extra.count = c.connector.extra.count or 5
        if fruit:matches(args, "cherry") then
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
      },
      name = "Quintuplets",
      pool = "default"
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
      },
      name = "Power On",
      pool = "default"
    },

    allonred = {
      rarity = RARE,
      c_args = {nil,RARE},
      cost = 7,
      check_when = "timer",
      func = function(c, args)
        return math.floor(game.timer) == 1 and therandomize(1, 2)
      end,
      desc = {
        "Triggers when the %btimer%! hits 1,",
        "with a 50% chance"
      },
      name = "All On Red",
      pool = "default"
    },

    downgrade = {
      rarity = UNCOMMON,
      c_args = {nil,UNCOMMON},
      cost = 4,
      desc = {
        "80% chance to trigger when a %yConnector%!",
        "activates another %yConnector%! of a lower %rrarity%!",
        "%I(EXAMPLE: An Uncommon trigger activating a Common trigger)"
      },
      name = "Downgrade",
      pool = "default"
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
      },
      name = "Standstill",
      pool = "default"
    },

    consumably = {
      rarity = UNCOMMON,
      c_args = {nil,UNCOMMON},
      cost = 6,
      check_when = "consumable",
      desc = {
        "Triggers when you use a %yconsumable%!",
      },
      name = "Yummy Delicious",
      pool = "default"
    },

    extension = {
      rarity = COMMON,
      c_args = {nil,COMMON},
      cost = 3,
      start_round = function(c)
        c.connector.extra.val = 100
      end,
      func = function(c)
        local res = therandomize(c.connector.extra.val or 0, 100)
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
      },
      name = "Extended Tendency",
      pool = "default"
    },

    pingpong = {
      rarity = COMMON,
      c_args = {nil,COMMON},
      cost = 3,
      check_when = "wall",
      start_round = function(c)
        c.connector.extra.val = "right"
      end,
      func = function(c, args)
        local res = c.connector.extra.val == args
        if not res then
          return false
        end
        if c.connector.extra.val == "right" then
          c.connector.extra.val = "left"
        else
          c.connector.extra.val = "right"
        end
        return true
      end,
      extra_info = function(c)
        return {
          (c.connector.extra.val or  "right")
        }
      end,
      desc = {
        "Triggers when you hit the right wall",
        "Switches which wall you have to hit"
      },
      name = "Ping Pong",
      pool = "default"
    },

    slipup = {
      rarity = COMMON,
      c_args = {nil,COMMON},
      cost = 3,
      check_when = "miss",
      func = function(c)
        return therandomize(1,2)
      end,
      desc = {
        "%y50% chance%! to trigger when",
        "you drop a fruit",
      },
      name = "Whoops",
      pool = "default"
    },

    spawnability = {
      rarity = COMMON,
      c_args = {nil,COMMON},
      cost = 6,
      check_when = "spawn",
      func = function(c, args)
        return fruit:matches(args, "grape") or fruit:matches(args, "grapes") --do later im tired i got 5 hours of sleep
      end,
      desc = {
        "Triggers when %pGrape%!(s) are",
        "%ospawned%! or %rdropped%!"
      },
      name = "Marbles",
      pool = "default"
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
      },
      name = "Temporal Savings",
      pool = "default"
    },

    thesacredmontra = {
      rarity = RARE,
      c_args = {nil,RARE},
      cost = 9,
      check_when = "collect",
      start_round = function(c)
        c.connector.extra.last_fruit = ""
      end,
      func = function(c, args, forced_)
        if forced_ then
          return true
        end

        if (c.connector.extra.last_fruit == "" or c.connector.extra.last_fruit == "apple") and fruit:matches(args, "apple") then
          c.connector.extra.last_fruit = "apple"
        elseif c.connector.extra.last_fruit == "apple" and fruit:matches(args, "orange") then
          c.connector.extra.last_fruit = "orange"
        elseif c.connector.extra.last_fruit == "orange" and fruit:matches(args, "banana") then
          c.connector.extra.last_fruit = ""
          return true
        else
          c.connector.extra.last_fruit = ""
        end
        return false
      end,
      desc = {
        "Triggers when you %gcollect%! an",
        "%rApple%!, then an %oOrange%!, then",
        "a B%yanana%! consecutively"
      },
      name = "The Sacred Montra",
      pool = "default"
    },

    debug = {
      rarity = RARE,
      c_args = {nil,RARE},
      cost = 0,
      check_when = "debug",
      name = "DEBUG",
      pool = "debug"
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
      },
      name = "A Point",
      pool = "default"
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
      },
      name = "Karma",
      pool = "default"
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
      },
      name = "A Handful Of Points",
      pool = "default"
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
      },
      name = "A School Of Points",
      pool = "default"
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
      },
      name = "Top of the Hill",
      pool = "default"
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
      },
      name = "Right Triangle",
      pool = "default"
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
      },
      name = "Seedling",
      pool = "default"
    },

    chumpchange = {
      rarity = RARE,
      c_args = {RARE, nil},
      cost = 8,
      func = function(c)
        if (game.money == 0) then
          game.money = game.money + 7
        end
      end,
      desc = {
        "If you have %y0$%!,",
        "Gain %y7$%!",
      },
      name = "Chump Charity",
      pool = "default"
    },

    beanstalk = {
      rarity = UNCOMMON,
      c_args = {UNCOMMON, nil},
      cost = 9,
      func = function(c)
        local cparent = c.parent
        while cparent do
          if therandomize(1, 10) then
            cparent.connector.perma_bonus = cparent.connector.perma_bonus + 1
          end
          cparent = cparent.parent
        end
        game:gain(3)
      end,
      desc = {
        "%g+3 points%!",
        "Above %yConnectors%! have a %y10% chance%!",
        "to gain %g+1 permanent point%!"
      },
      name = "Beanstalk",
      pool = "default"
    },

    plusorminus = {
      rarity = COMMON,
      c_args = {COMMON, nil},
      cost = 1,
      start_round = function(c)
        c.connector.extra.val = 1
      end,
      func = function(c)
        game:gain(11 * c.connector.extra.val)
        c.connector.extra.val = c.connector.extra.val * -1
      end,
      extra_info = function(c)
        return {
          tostring(c.connector.extra.val or 1)
        }
      end,
      desc = {
        "Alternates between",
        "%g+11 points%! and",
        "%r-11 points%!"
      },
      name = "Plus or Minus",
      pool = "default"
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
      },
      name = "LOSE!!! AAAAHHHHH",
      pool = "debug"
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
      },
      name = "Magnet",
      pool = "default"
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
      },
      name = "^",
      pool = "default"
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
      },
      name = "v",
      pool = "default"
    },

    qol = {
      rarity = COMMON,
      c_args = {COMMON, nil},
      cost = 6,
      func = function(c)
        local rfruit = therandomize(1, #fruit.fruits)
        if fruit.fruits[rfruit] ~= nil then
          fruit:add_bonus(fruit.fruits[rfruit], fruit:random_bonus())
        end
      end,
      desc = {
        "Adds a random %ybonus%!",
        "to a random onscreen fruit"
      },
      name = "Quality of Life",
      pool = "default"
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
      },
      name = "Shapeshift",
      pool = "default"
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
      },
      name = "Faulty Mutation",
      pool = "default"
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
      },
      name = "Lottery Ticket",
      pool = "default"
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
      },
      name = "Creative Mode",
      pool = "default"
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
      },
      name = "Negative Space",
      pool = "default"
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
      },
      name = "Double Dip",
      pool = "default"
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
      },
      name = "Penny Pinching",
      pool = "default"
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
      },
      name = "Abundance",
      pool = "default"
    },

    composter = {
      rarity = UNCOMMON,
      c_args = {UNCOMMON, nil},
      cost = 3,
      func = function(c)
        for i = 0, love.math.random(0,5) do
          if i ~= 0 then
            fruit_spawner:spawn({fruit = fruit_types:random()}, true)
          end
        end
      end,
      desc = {
        "Spawns a random amount of random fruits",
      },
      name = "Composter",
      pool = "default"
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
      },
      name = "Fruit Bowl",
      pool = "default"
    },

    snakeeyes = {
      rarity = UNCOMMON,
      c_args = {UNCOMMON, nil},
      cost = 5,
      func = function(c)
        game:gain((c.connector.extra.value or 0) * 2 )
      end,
      extra_info = function(c)
        return {
          "+" .. tostring((c.connector.extra.value or 0) * 2)
        }
      end,
      desc = {
        "This trigger gains %g+2 points%!",
        "for each %yReroll%! taken after purchase",
      },
      name = "Snake Eyes",
      pool = "default"
    },

    afewmore = {
      rarity = UNCOMMON,
      c_args = {UNCOMMON, nil},
      cost = 5,
      start_round = function(c)
        c.connector.extra = {}
      end,
      func = function(c)
        c.connector.extra.uses = (c.connector.extra.uses or 0) + 2
        if (c.connector.extra.uses <= 9) then
          game.timer = game.timer + 3
        end
      end,
      extra_info = function(c)
        return {
          (c.connector.extra.uses or 0) .. "/9"
        }
      end,
      desc = {
        "+2 seconds on the %btimer%!",
        "9 uses"
      },
      name = "Stopwatch",
      pool = "default"
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
        if (c.connector.extra.uses == 3) then
          game.timer = game.timer + 45
        end
      end,
      extra_info = function(c)
        return {
          (c.connector.extra.uses or 0) .. "/2"
        }
      end,
      desc = {
        "After 3 uses,",
        "+45 seconds on the %btimer%!"
      },
      name = "Alarm Clock",
      pool = "default"
    },

    highspawn = {
      rarity = RARE,
      c_args = {RARE, nil},
      cost = 6,
      func = function(c)
        fruit_spawner.spawnrate = fruit_spawner.spawnrate / 1.15
      end,
      desc = {
        "%g15%%! faster %gspawn rate%! for rest of round"
      },
      name = "Fertilizer",
      pool = "default"
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
      },
      name = "Boost Orb",
      pool = "default"
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
        "If there are no %oOranges%! on screen,",
        "spawn an %oOrange%!",
      },
      name = "Tangerine",
      pool = "default"
    },

    fork = {
      rarity = COMMON,
      c_args = {COMMON, nil},
      cost = 2,
      func = function(c)
        spawns:spawn("fork", player.x, player.y)
        spawns:spawn("fork", player.x, player.y)
      end,
      desc = {
        "Spawn 2 Forks",
        "Forks collect fruits they pass",
        "and score them one additional time"
      },
      name = "Fork",
      pool = "spawners"
    },

    spoon = {
      rarity = COMMON,
      c_args = {COMMON, nil},
      cost = 2,
      func = function(c)
        spawns:spawn("spoon", player.x, player.y)
      end,
      desc = {
        "Spawn a Spoon",
        "Spoons activate collect triggers",
        "for the first fruit they hit",
        "without destroying the fruit"
      },
      name = "Spoon",
      pool = "spawners"
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
      },
      name = "Banana Planet",
      pool = "default"
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
      },
      name = "Cherry Picking",
      pool = "default"
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
      },
      name = "T Minus",
      pool = "default"
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
      },
      name = "Citrus",
      pool = "default"
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
      },
      name = "Meteorite",
      pool = "default"
    },

    bigging = {
      rarity = UNCOMMON,
      c_args = {UNCOMMON, nil},
      cost = 5,
      func = function(c)
        player.size = player.size * 1.07
      end,
      desc = {
        "Get %g7% bigger%!",
      },
      name = "Sprout",
      pool = "default"
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
      },
      name = "Three Star Rating",
      pool = "default"
    },

    big = {
      rarity = RARE,
      c_args = {RARE, nil},
      cost = 1,
      start_round = function(c)
        c.connector.extra = {}
      end,
      func = function(c)
        player.size = DEFAULT_SIZE * 3
      end,
      desc = {
        "get BIG"
      },
      name = "Overgrowth",
      pool = "default"
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
      },
      name = "RNA",
      pool = "default"
    },

    agrape = {
      rarity = RARE,
      c_args = {RARE, nil},
      cost = 7,
      start_round = function(c)
        game.grape_bonus = 0
      end,
      func = function(c)
        fruit_spawner:spawn({fruit = "grapes"})
        fruit_spawner:spawn({fruit = "grapes"})
        fruit_spawner:spawn({fruit = "grapes"})
        game.grape_bonus = game.grape_bonus + 2
      end,
      desc = {
        "Spawns 3 %pGrape bushels%!",
        "%pGrape bushels%! spawn 2 additional %pGrape%!s"
      },
      name = "Grapeshot",
      pool = "default"
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
      },
      name = "Weather Alert",
      pool = "default"
    },

    topten = {
      rarity = COMMON,
      c_args = {COMMON, UNCOMMON},
      cost = 6,
      func = function(c)
        return (game.timer <= 10)
      end,
      desc = {
        "Triggers if the %btimer%!",
        "is %y10%! or less"
      },
      name = "Top 10",
      pool = "default"
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
      },
      name = "Boom",
      pool = "default"
    },

    once = {
      rarity = UNCOMMON,
      c_args = {UNCOMMON, RARE},
      cost = 5,
      start_round = function(c)
        c.connector.extra = {}
      end,
      func = function(c)
        local p = c.connector.extra.val or 0
        c.connector.extra.val = p + 1
        return (c.connector.extra.val == 5)

      end,
      desc = {
        "Triggers once per round",
        "after 5 attempts",
      },
      name = "One",
      pool = "default"
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
          c.connector.extra.val = 10
          return therandomize(1,2)
        end
        return false

      end,
      update = function(c, dt)
        if c.connector.extra.val ~= nil and c.connector.extra.val >= 0 then
          c.connector.extra.val = c.connector.extra.val - dt
        end
      end,
      extra_info = function(c)
        return {
          tostring(c.connector.extra.val or 10)
        }
      end,
      desc = {
        "When triggered, cannot be triggered again for %y10%! seconds",
        "%g50% chance%! to work"
      },
      name = "Spin The Wheel",
      pool = "default"
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
      },
      name = "Zero Gravity",
      pool = "default"
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
      },
      name = "G Force",
      pool = "default"
    },

    nothingleft = {
      rarity = COMMON,
      c_args = {COMMON, UNCOMMON},
      cost = 6,
      func = function(c)
        return game.pts == 0
      end,
      desc = {
        "Triggers if you have %y0%! %gpoints%!"
      },
      name = "Blank",
      pool = "default"
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
      },
      name = "Suspicious Man",
      pool = "default"
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
      },
      name = "Incredibly Suspicious Man",
      pool = "default"
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
      },
      name = "The Rice",
      pool = "default"
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
      },
      name = "Appling",
      pool = "default"
    },

    varietyistheslice = {
      rarity = COMMON,
      c_args = {COMMON, UNCOMMON},
      cost = 4,
      func = function(c)
        local appling, oranging, bananing = false, false, false
        for i, j in ipairs(fruit.fruits) do
          if fruit:matches(j, "apple", j) then
            appling = true
          end
          if fruit:matches(j, "orange", j) then
            oranging = true
          end
          if fruit:matches(j, "banana", j) then
            bananing = true
          end
        end
        return appling and oranging and bananing
      end,
      desc = {
        "Triggers if there's an",
        "%rApple%!, %oOrange%!, and %yBanana%!",
        "on screen"
      },
      name = "Balanced Breakfast",
      pool = "default"
    },

    huh = {
      rarity = COMMON,
      c_args = {COMMON, COMMON},
      cost = 1,
      desc = {
        "Always triggers, does nothing else"
      },
      name = "??????",
      pool = "default"
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
      },
      name = "Next Up",
      pool = "default"
    },

    seasontwo = {
      rarity = RARE,
      c_args = {RARE, RARE},
      cost = 3,
      func = function(c, args)
        game:gain(30)
      end,
      desc = {
        "%g+30 points%! then triggers"
      },
      name = "Season Two",
      pool = "default"
    },

    lol = {
      rarity = COMMON,
      c_args = {nil, nil},
      cost = 1,
      desc = {
        "lol"
      },
      name = "Lol",
      pool = "debug"
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

  return format_desc(txt)
end

function format_desc(txt)

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
