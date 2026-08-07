local debug_mode = {
  type = "bool-setting",
  name = "nbg-debug-setting",
  setting_type = "startup",
  default_value = false
}

local min_radius_setting = {
  type = "int-setting",
  name = "nbg-min-radius-setting",
  setting_type = "startup",
  default_value = 224,
  minimum_value = 200
}

data.extend({debug_mode, min_radius_setting})