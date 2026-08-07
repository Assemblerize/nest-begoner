require("__nest-begoner__.scripts.misc")

local major_minor = get_factorio_version()

local repellent_recipe = {
  type = "recipe",
  name = "nbg-expansion-repellent",
  icon = "__nest-begoner__/sprites/icons/Icon.png",
  icon_size = 64,
  enabled = false,
  energy_required = 40,
  --category = "crafting",
  subgroup = "defensive-structure",
  order = "d[radar]-b[expansion-repellent]",
  
  --factoriopedia_alternative = "nbg-expansion-repellent-holdable",
  ingredients = {
      {type = "item", name = "advanced-circuit", amount = 100},
      {type = "item", name = "steel-plate", amount = 100},
      {type = "item", name = "accumulator", amount = 20},
      {type = "item", name = "radar", amount = 5}
  },
  results = {{type = "item", name = "nbg-expansion-repellent", amount = 1}}
}

if major_minor == "2.1" then
  repellent_recipe.categories = {"crafting"}
else
  repellent_recipe.category = "crafting"
end

data:extend({repellent_recipe})