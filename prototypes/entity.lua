local repellent = {
  type = "electric-energy-interface",
  name = "nbg-expansion-repellent",
  icon = "__nest-begoner__/sprites/icons/Icon.png",
  icon_size = 64,
  max_health = 500,
  flags = {"placeable-player", "player-creation", "not-rotatable"},
  subgroup = "defensive-structure",
  order = "z-d[radar]-b[expansion-repellent]",
  collision_box = {{-2.4, -2.4}, {2.4, 2.4}},
  selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
  is_military_target = true,
  random_variation_on_create = false,
  drawing_box_vertical_extension = 1.3,
  collision_mask = {layers={item=true, object=true, player=true, water_tile=true, elevated_rail=true, is_object=true, is_lower_object=true}},

  --hidden = true,
  --hidden_in_factoriopedia = true,

  minable = {mining_time = 0.5, result = "nbg-expansion-repellent"},
  placeable_by = {item = "nbg-expansion-repellent", count = 1},

  gui_mode = "none",
  continuous_animation = true,
  tall = true,

  dying_explosion = "oil-refinery-explosion",
  impact_category = "metal-large",

  energy_usage = "7.5MW",
  energy_source = {
    type = "electric",
    usage_priority = "secondary-input",
    buffer_capacity = "200MJ",
    input_flow_limit = "15MW",
    output_flow_limit = "0kW",
    --drain = "0kW"
  },

  render_layer = "object",
  corpse = "nbg-repellent-corpse",

  picture = {
    layers = {
      {
        filename = "__nest-begoner__/sprites/base.png",
        priority = "extra-high",
        width = 544,
        height = 544,
        shift = {0, -1},
        scale = 0.5
      },
      {
        filename = "__nest-begoner__/sprites/small_screens.png",
        priority = "extra-high",
        width = 544,
        height = 544,
        shift = {0, -1},
        scale = 0.5,
        draw_as_glow = true,
        blend_mode = "additive"
      },
      {
        filename = "__nest-begoner__/sprites/base_shadow.png",
        priority = "extra-high",
        width = 544,
        height = 544,
        shift = {1.5, -1},
        scale = 0.5,
        draw_as_shadow = true
      }
    }
  },

  integration_patch = {
    filename = "__nest-begoner__/sprites/integration.png",
    priority = "low",
    width = 544,
    height = 544,
    shift = {0, -1},
    scale = 0.5
  },

  water_reflection = {
    rotate = false,
    orientation_to_variation = false,
    pictures = {
      filename = "__nest-begoner__/sprites/water_reflection.png",
      priority = "extra-high",
      width = 430,
      height = 610,
      shift = {0, 2.5},
      scale = 0.5,
      variation_count = 1
    }
  },

  working_sound = {
    sound = {
      filename = "__nest-begoner__/sound/idle2.ogg",
      volume = 0.8,
      modifiers = volume_multiplier("main-menu", 2.0)
    },
    max_sounds_per_prototype = 3,
    use_doppler_shift = false
  },

  resistances = {
    { type = "fire", percent = 60 },
    { type = "impact", percent = 30 }
  }
}


local corpse = {
  type = "corpse",
  name = "nbg-repellent-corpse",
  icon = "__nest-begoner__/sprites/icons/Icon.png",
  flags = {"placeable-neutral", "not-on-map"},
  --hidden_in_factoriopedia = true,
  subgroup = "defensive-structure-remnants",
  order = "a-a-a",
  --collision_box = {{-2.4, -2.2}, {2.4, 2.4}},
  selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
  tile_width = 5,
  tile_height = 5,
  selectable_in_game = false,
  time_before_removed = 60 * 60 * 15, -- 15 minutesasss
  expires = false,
  final_render_layer = "remnants",
  remove_on_tile_placement = false,
  drawing_box_vertical_extension = 1.3,
  animation = {
    filename = "__nest-begoner__/sprites/remnants/begoner-remnants.png",
    line_length = 1,
    width = 384,
    height = 384,
    direction_count = 1,
    --shift = {0, 0},
    scale = 0.5
  }
}


data:extend({corpse, repellent})