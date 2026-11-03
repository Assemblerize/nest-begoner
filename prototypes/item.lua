local repellent_item = {
  type = "item",
  name = "nbg-expansion-repellent",
  icon = "__nest-begoner__/sprites/icons/Icon.png",
  icon_size = 64,
  flags = {},
  subgroup = "defensive-structure",
  order = "d[radar]-b[expansion-repellent]",
  place_result = "nbg-expansion-repellent",
  stack_size = 10
}

data:extend({repellent_item})