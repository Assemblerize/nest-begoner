local repellent_technology = {
    type = "technology",
    name = "nbg-expansion-repellent-tech",
    icon = "__nest-begoner__/sprites/icons/begoner_tech.png",
    icon_size = 256,
    effects = {
      {
        type = "unlock-recipe",
        recipe = "nbg-expansion-repellent"
      }
    },
    prerequisites = {"chemical-science-pack", "military-science-pack", "radar", "electric-energy-accumulators"},
    unit = {
      count = 300,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"military-science-pack", 1}
      },
      time = 30
    },
    order = "a-b-c"
}

data:extend({repellent_technology})