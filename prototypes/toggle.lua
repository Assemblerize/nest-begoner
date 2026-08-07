local circle_toggle = {
  type = "shortcut",
  name = "nbg-toggle-my-circles",
  toggleable = true,
  unavailable_until_unlocked = true,
  technology_to_unlock = "nbg-expansion-repellent-tech",
  action = "lua",
  icon = "__nest-begoner__/sprites/icons/Icon.png",
  small_icon = "__nest-begoner__/sprites/icons/Icon.png",
  hidden = false
}
data:extend({circle_toggle})

if settings.startup["nbg-debug-setting"].value then
  local debug_button = {
    type = "shortcut",
    name = "nbg-debug-toolbar-button",
    toggleable = false,
    unavailable_until_unlocked = false,
    action = "lua",
    icon = "__base__/graphics/icons/water-wube.png",
    small_icon = "__base__/graphics/icons/water-wube.png",
    localised_name = "Begoner test button"
  }
  data:extend({debug_button})
end