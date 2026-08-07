require("__nest-begoner__.scripts.misc")

-- Leaving only really existing tech
local function safe_prerequisites(list)
  local result = {}
  for _, tech_name in pairs(list) do
    if data.raw.technology[tech_name] then
      table.insert(result, tech_name)
    else
      begoner_log(false, false, "Prerequisite '%s' not found, skipping for compatibility", tech_name)
    end
  end
  return result
end

-- Leaving only real science packs
local function safe_ingredients(list)
  local result = {}
  for _, ing in pairs(list) do
    local pack_name = ing[1]
    local exists =
      (data.raw.tool and data.raw.tool[pack_name]) or
      (data.raw.item and data.raw.item[pack_name])
    if exists then
      table.insert(result, ing)
    else
      begoner_log(false, false, "Science pack '%s' not found, skipping", pack_name)
    end
  end
  return result
end

local prerequisites = safe_prerequisites({
  "chemical-science-pack",
  "military-science-pack",
  "radar",
  "electric-energy-accumulators"
})

local ingredients = safe_ingredients({
  {"automation-science-pack", 1},
  {"logistic-science-pack", 1},
  {"chemical-science-pack", 1},
  {"military-science-pack", 1}
})

-- Rare case of everything broken
if #ingredients == 0 then
  ingredients = {{"automation-science-pack", 1}}
end

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
  prerequisites = prerequisites,
  unit = {
    count = 300,
    ingredients = ingredients,
    time = 30
  },
  order = "a-b-c"
}

data:extend({repellent_technology})


--- Quality support

local function build_quality_values()
  local quality_values = {}
  for name, quality in pairs(data.raw["quality"]) do
    if name ~= "quality-unknown" then
      quality_values[name] = string.format(calculate_raduius_value(quality.level or 0))
    end
  end
  return quality_values
end

local quality_values = build_quality_values()

local custom_tooltip = {
  name = {"description.range"},
  value = {string.format(calculate_raduius_value(0))}, -- fallback = normal
  quality_header = "quality-tooltip.increases",
  quality_values = quality_values,
}

for _, proto in pairs({
  data.raw["electric-energy-interface"]["nbg-expansion-repellent"],
  data.raw["electric-energy-interface"]["nbg-expansion-repellent-holdable"],
}) do
  if proto then
    proto.custom_tooltip_fields = proto.custom_tooltip_fields or {}
    table.insert(proto.custom_tooltip_fields, custom_tooltip)
  end
end