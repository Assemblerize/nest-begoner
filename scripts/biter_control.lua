--local AsyncChunkScanner = require("__nest-begoner__.scripts.grid_analyzer")

-- Force biter group to flee
function change_biter_state(biter_group, repellent)
  begoner_log(false, true, "Attempting to stop base creation...")
  biter_group.set_command({
    type = defines.command.flee,
    from = repellent,
    distraction = defines.distraction.by_enemy
  })
  begoner_log(false, true, "Biters are now %d", biter_group.state)
end

local function send_biters(surface, force, sg_min_size, sg_max_size, cx, cy, score)
  -- rendering.draw_rectangle{
  --   color = {1 - score, score, 0},
  --   width = 40,
  --   left_top = {cx * 32 + 3, cy * 32 + 3},
  --   right_bottom = {cx * 32 + 29, cy * 32 + 29},
  --   surface = surface,
  --   render_mode = "chart"
  -- }

  local evo = force.get_evolution_factor(surface)

  local min_size = math.floor(sg_min_size + (sg_max_size - sg_min_size) * evo * 0.5)
  local max_size = math.floor(sg_min_size + (sg_max_size - sg_min_size) * evo)

  min_size = math.max(4, min_size)
  max_size = math.max(min_size, max_size)

  local group_size = math.random(min_size, max_size)

  local tile_x = cx * 32 + math.random(0, 31)
  local tile_y = cy * 32 + math.random(0, 31)

  surface.build_enemy_base({ tile_x, tile_y }, group_size, force)
end




local function up_the_evolution(surface, force, kill_count)
  local current_ev_kill_factor = force.get_evolution_factor_by_killing_spawners(surface)
  local total_evolution = force.get_evolution_factor(surface)
  local setting_ev_kill_factor = game.map_settings.enemy_evolution.destroy_factor

  local new_kill_factor = current_ev_kill_factor + kill_count * setting_ev_kill_factor * (1 - total_evolution)
  new_kill_factor = math.min(1.0, math.max(0.0, new_kill_factor))
  force.set_evolution_factor_by_killing_spawners(new_kill_factor, surface)
end


function trigger_consequences(scanner_id, pos_x, pos_y, radius, surface, force, kill_count)
  
  -- rendering.clear()

  up_the_evolution(surface, force, kill_count)
  
  local exclusion = {
    x = pos_x,
    y = pos_y,
    r = radius * 1.2
  }

  -- rendering.draw_circle{
  --   color = {0, 0, 1},
  --   width = 40,
  --   target = { pos_x , pos_y },
  --   radius = radius,
  --   surface = surface,
  --   render_mode = "chart"
  -- }

  local scan_center_in_chunks = surface.get_random_chunk()
  local scan_diameter = 5

  local startX = scan_center_in_chunks.x - scan_diameter
  local startY = scan_center_in_chunks.y - scan_diameter
  local endX = scan_center_in_chunks.x + scan_diameter
  local endY = scan_center_in_chunks.y + scan_diameter

  -- rendering.draw_rectangle{
  --   color = {0, 0, 1},
  --   width = 40,
  --   left_top = {startX * 32, startY * 32},
  --   right_bottom = {endX * 32 + 32, endY * 32 + 32},
  --   surface = surface,
  --   render_mode = "chart"
  -- }



  -- Start async scan
  AsyncChunkScanner.start_scan(scanner_id, surface, startX, startY, endX, endY, exclusion,
    game.map_settings.enemy_expansion, force, send_biters)

end
