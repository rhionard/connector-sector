playerdata = {
  hoarse = {
    sprites = {
      idle = "idlebasket.png",
      jump = "walk2basket.png",
      cycle = {"jumpbasket.png", "walk2basket.png"}
    },
    name = "Chor",
    init = function()
      for i = 1, 2 do
        fruit_spawner:add_to_deck("blueberries", {boosted = true})
        fruit_spawner:add_to_deck("apple")
        fruit_spawner:add_to_deck("apple")
        fruit_spawner:add_to_deck("bombfruit")
        fruit_spawner:add_to_deck("bombfruit")
      end
    end
  },
  manguyperson = {
    sprites = {
      idle = "idlebasket.png",
      jump = "jumpbasket.png",
      cycle = {"jumpbasket.png"}
    },
    name = "Blue",
    init = function()
      for i = 1, 2 do
        fruit_spawner:add_to_deck("apple")
        fruit_spawner:add_to_deck("banana")
        fruit_spawner:add_to_deck("watermelon")
        fruit_spawner:add_to_deck("cherry")
        fruit_spawner:add_to_deck("bombfruit")
      end
    end
  }
}
