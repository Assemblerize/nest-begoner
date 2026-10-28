require("__nest-begoner__.scripts.misc")
require("__nest-begoner__.scripts.animation_control")
require("__nest-begoner__.scripts.blueprint")
require("__nest-begoner__.scripts.status_control")
require("__nest-begoner__.scripts.effect_radius_control")
require("__nest-begoner__.scripts.registration")
require("__nest-begoner__.scripts.biter_control")
require("__nest-begoner__.scripts.action")
AsyncChunkScanner = require("__nest-begoner__.scripts.grid_analyzer")

local function sync_button_toggled(player)
  if not (player and player.valid) then return end
  player.set_shortcut_toggled("nbg-toggle-my-circles", is_viewer(player.index))
end

local function add_viewer_all()
  for _, player in pairs(game.players) do add_viewer(player) end
end


-- First blood. Init for settings
script.on_init(function()
  storage.repellent_data = {}
  storage.circle_viewer_index = {}
  add_viewer_all()
end)

-- Eh, second and other bloods. Fix viewership for players that existed before the mod was added
script.on_configuration_changed(function()
  storage.repellent_data = storage.repellent_data or {}
  storage.circle_viewer_index = storage.circle_viewer_index or {}
  add_viewer_all()
end)


script.on_load(function()
  if storage.scanners and next(storage.scanners) ~= nil then
    script.on_nth_tick(1, AsyncChunkScanner.on_tick)
  end
end)


-- Handle multi: fix viewership for the new players
script.on_event(defines.events.on_player_created, function(event)
  local player_index = event.player_index
  local player = game.get_player(player_index)
  add_viewer(player)
end)

-- Handling a possible toggle desynchronization
script.on_event(defines.events.on_player_joined_game, function(event)
  local player = game.get_player(event.player_index)
  sync_button_toggled(player)
end)

-- Cleanup if a player was removed
script.on_event(defines.events.on_player_removed, function(event)
  storage.circle_viewer_index[event.player_index] = nil
  updateAllCircles()
end)

-- Register for biters' arrival
script.on_event(defines.events.on_build_base_arrived, repel_biters_function)



local event_filter = {
  { filter = "name", name = "nbg-expansion-repellent" } }
-- Registering entities
script.on_event(defines.events.on_built_entity, register_repellent, event_filter)
script.on_event(defines.events.on_robot_built_entity, register_repellent, event_filter)
script.on_event(defines.events.script_raised_built, register_repellent, event_filter)
script.on_event(defines.events.script_raised_revive, register_repellent, event_filter)

-- Register to handle blueprints
script.on_event(defines.events.on_player_setup_blueprint, blueprint_handling)

-- Deregistering entities
script.on_event(defines.events.on_object_destroyed, deregister_repellent)

-- Handle death
script.on_event(defines.events.on_entity_died, swap_ghost, event_filter)

-- Handle marked for deconstruction
script.on_event(defines.events.on_marked_for_deconstruction, updateMarkedForDeconstructionStatus, event_filter)
script.on_event(defines.events.on_cancelled_deconstruction, updateMarkedForDeconstructionStatus, event_filter)


--script.on_event(defines.events.on_pre_build, swap_quality)

-- Shortcuts
function button_press(event)
  if event.prototype_name == "nbg-toggle-my-circles" then
    toggle_circles(event)
  elseif event.prototype_name == "nbg-debug-toolbar-button" then
    debug_button()
  end
end

script.on_event(defines.events.on_lua_shortcut, button_press)

-- Register for energy depletion check
script.on_nth_tick(30, updateAllRepellentStatuses)
