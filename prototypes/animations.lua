local repellent_animation_bottom = {
  type = "animation",
  name = "nbg-repellent-animation-bottom",
  filename = "__nest-begoner__/sprites/animation_bottom.png",
  width = 544,
  height = 544,
  frame_count = 64,
  line_length = 8,
  animation_speed = 1,
  shift = {0, -1},
  scale = 0.5
}


-- This one is needed separately to do a proper overlap with protruding stuff like artillery
-- It looks odd if the top of a repellent is drawn under the muzzle
local repellent_animation_top = {
  type = "animation",
  name = "nbg-repellent-animation-top",
  layers = {
    {
      filename = "__nest-begoner__/sprites/animation_top.png",
      width = 544,
      height = 544,
      frame_count = 64,
      line_length = 8,
      animation_speed = 1,
      shift = {0, -1},
      scale = 0.5
    },
    {
      filename = "__nest-begoner__/sprites/animation_shadow.png",
      width = 544,
      height = 544,
      frame_count = 64,
      line_length = 8,
      animation_speed = 1,
      shift = {1.5, -1},
      draw_as_shadow = true,
      scale = 0.5
    }
  }
}




local screen_animation = {
  type = "animation",
  name = "nbg-working-screen-animation",
  filename = "__nest-begoner__/sprites/screen.png",
  width = 544,
  height = 544,
  frame_count = 64,
  line_length = 8,
  animation_speed = 1,
  shift = {0, -1},
  draw_as_glow = true,
  scale = 0.5,
  blend_mode = "additive"
}

local screen_no_charge_animation = {
  type = "animation",
  name = "nbg-no-charge-animation",
  filename = "__nest-begoner__/sprites/no_charge.png",
  width = 544,
  height = 544,
  frame_count = 2,
  line_length = 2,
  animation_speed = 1,
  shift = {0, -1},
  draw_as_glow = true,
  scale = 0.5,
  blend_mode = "additive"
}





local indicator_sprite = {
  type = "sprite",
  name = "nbg-indicator",
  filename = "__nest-begoner__/sprites/indicator.png",
  width = 544,
  height = 544,
  scale = 0.5,
  shift = {0, -1},
  draw_as_glow = true,
  blend_mode = "additive"
}

local charging_animation = {
  type = "animation",
  name = "nbg-charging-animation",
  filename = "__nest-begoner__/sprites/charging.png",
  width = 544,
  height = 544,
  frame_count = 64,
  line_length = 8,
  animation_speed = 1,
  shift = {0, -1},
  draw_as_glow = true,
  scale = 0.5,
  blend_mode = "additive"
}








local fire_animation_base = {
  type = "animation",
  name = "nbg-fire-animation-base",
  filename = "__nest-begoner__/sprites/action/action_electricity.png",
  width = 448,
  height = 448,
  frame_count = 32,
  line_length = 8,
  animation_speed = 1,
  shift = {0, -1},
  draw_as_glow = true,
  scale = 0.5,
  blend_mode = "additive"
}

local fire_animation_west = {
  type = "animation",
  name = "nbg-fire-animation-west",
  layers = {
    {
      filename = "__nest-begoner__/sprites/action/action_west.png",
      width = 576,
      height = 576,
      frame_count = 16,
      line_length = 4,
      animation_speed = 1,
      shift = {-7, -2.5},
      draw_as_glow = true,
      scale = 0.5,
      blend_mode = "additive"
    },
    {
      filename = "__nest-begoner__/sprites/action/glow_west.png",
      width = 256,
      height = 256,
      frame_count = 16,
      line_length = 4,
      animation_speed = 1,
      shift = {-1, -2.5},
      draw_as_glow = true,
      scale = 0.5,
      blend_mode = "additive"
    }
  }
}

local fire_animation_south = {
  type = "animation",
  name = "nbg-fire-animation-south",
  layers = {
    {
      filename = "__nest-begoner__/sprites/action/action_south.png",
      width = 576,
      height = 576,
      frame_count = 16,
      line_length = 4,
      animation_speed = 1,
      shift = {2.5, 2},
      draw_as_glow = true,
      scale = 0.5,
      blend_mode = "additive"
    },
    {
      filename = "__nest-begoner__/sprites/action/glow_south.png",
      width = 256,
      height = 256,
      frame_count = 16,
      line_length = 4,
      animation_speed = 1,
      shift = {-1, -2.5},
      draw_as_glow = true,
      scale = 0.5,
      blend_mode = "additive"
    }
  }
}

local fire_animation_north = {
  type = "animation",
  name = "nbg-fire-animation-north",
  filename = "__nest-begoner__/sprites/action/action_north.png",
  width = 576,
  height = 576,
  frame_count = 16,
  line_length = 4,
  animation_speed = 1,
  shift = {2.5, -7},
  draw_as_glow = true,
  scale = 0.5,
  blend_mode = "additive"
}

data:extend({
  repellent_animation_bottom,
  repellent_animation_top,
  screen_animation,
  screen_no_charge_animation,
  indicator_sprite,
  charging_animation,
  fire_animation_base,
  fire_animation_west,
  fire_animation_south,
  fire_animation_north})