local repellent_recipe = {
  type = "recipe",
  name = "nbg-expansion-repellent",
  icon = "__nest-begoner__/sprites/icons/Icon.png",
  icon_size = 64,
  enabled = false,
  energy_required = 20,
  --category = "crafting",
  subgroup = "defensive-structure",
  order = "d[radar]-b[expansion-repellent]",
  categories = {"crafting"},
  ingredients = {
      {type = "item", name = "advanced-circuit", amount = 100},
      {type = "item", name = "steel-plate", amount = 100},
      {type = "item", name = "accumulator", amount = 20},
      {type = "item", name = "radar", amount = 5}
  },
  results = {{type = "item", name = "nbg-expansion-repellent", amount = 1}}
}

data:extend({repellent_recipe})