local begoner_log = begoner_log
local draw_circle = draw_circle
local renderMainAnimation = renderMainAnimation
local renderIndicator = renderIndicator
local repellentStatusCheck = repellentStatusCheck
local calculate_raduius_value = calculate_raduius_value

-- Undo cleanup
local function undo_cleanup(player)
  begoner_log(false, true, "Cleaning up the undo queue...")
  if player == nil or not player.valid then return end
  local stack = player.undo_redo_stack
  for item_index = 1, stack.get_undo_item_count(), 1 do
    local item = stack.get_undo_item(item_index)
    if item ~= nil then
      for action_index = #item, 1, -1 do
        if item[action_index] ~= nil then
          local target = item[action_index].target
          if target ~= nil and target.name == "nbg-expansion-repellent-holdable" then
            stack.remove_undo_action(item_index, action_index)
          end
        end
      end
    end
  end
end

-- Replacing entity in hand
function replace_entity(holdable_entity, player_index)
  begoner_log(false, true, "Replacing entity in hand...")

  local surface = holdable_entity.surface
  local position = holdable_entity.position
  local force = holdable_entity.force
  local direction = holdable_entity.direction
  local quality = holdable_entity.quality
  
  local player = nil
  if player_index ~= nil then
    player = game.get_player(player_index)
  else
    player = holdable_entity.last_user
  end

  local real_entity = surface.create_entity{
    name = "nbg-expansion-repellent",
    position = position,
    force = force,
    direction = direction,
    quality = quality,
    --raise_built = true,
    player = player
  }

  if real_entity and holdable_entity.valid then
    --helpers.write_file("begoner.txt", "Holdable_entity is still valid\n", true)
    holdable_entity.destroy{player = player}
  end

  --Clean up undo queue
  undo_cleanup(player)

  return real_entity
end

-- Register repellent_entity
function register_repellent(event)
  begoner_log(false, true, "Registering repellent... Source: %d", event.name)
  local entity = event.entity
  
  if entity.name == "nbg-expansion-repellent-holdable" then
    entity = replace_entity(event.entity, event.player_index)
  end
  local _, useful_id = script.register_on_object_destroyed(entity)     -- Register the entity for destruction and its circle
  local radius = calculate_raduius_value(entity.quality.level)
  storage.repellent_data[useful_id] = {
    entity = entity,
    last_energy = 0,
    status = 0,
    growing = false,
    frags = 0,
    radius = radius,
    charging_animation = nil,
    screen_animation = nil,
    animation = renderMainAnimation(entity),
    indicator = renderIndicator(entity),
    circle = draw_circle(entity, radius)
  }

  if get_factorio_version() ~= "2.0" then
    entity.set_tooltip_field({id = 555, name = {"custom-tooltip.nbg-frags"}, value = "0", order = 100})
  end
  repellentStatusCheck(storage.repellent_data[useful_id])
  begoner_log(false, true, "Repellent registered with ID: %d", useful_id)
end

--Deregister repellent_entity
function deregister_repellent(event)
  local useful_id = event.useful_id
  begoner_log(false, true, "Removing repellent: %d", useful_id)


  if storage.repellent_data then

    --Remove from the data table
    storage.repellent_data[useful_id] = nil -- clear storage
    AsyncChunkScanner.stop_scan(useful_id) -- clear scanners if present
    begoner_log(false, true, "Data removed")
  end
end

--Handle death
function swap_ghost(event)
  local dying_entity = event.entity
  if dying_entity.name ~= "nbg-expansion-repellent" then return end

  local surface  = dying_entity.surface

  -- Player?
  local position = dying_entity.position
  local direction = dying_entity.direction
  local quality = dying_entity.quality
  local force = dying_entity.force

  dying_entity.destroy()

  local temp_entity = surface.create_entity{
    name = "nbg-expansion-repellent-holdable",
    position = position,
    direction = direction,
    quality = quality,
    force = force
  }

  local cause = event.cause
  local killing_force = event.force
  temp_entity.die(killing_force, cause)
end



function swap_quality(event)
  local player = game.get_player(event.player_index)
  if player == nil then return end
  
  local stack = player.cursor_stack
  if not (stack and stack.valid_for_read and stack.name == "nbg-expansion-repellent-holdable") then return end

  local old = player.surface.find_entity("nbg-expansion-repellent", event.position)
  if not old or old.direction ~= event.direction then return end
  if old.quality.name == stack.quality.name then return end -- нет смысла, и это небезопасно (см. ниже)

  -- то, что fast_replace не переносит сам
  local mirroring = old.mirroring
  local health = old.health
  -- + всё, что вы храните в своём storage по old.unit_number
  local frags = storage.repellent_data[old.unit_number].frags

  local new = old.surface.create_entity{
    name = "nbg-expansion-repellent",
    position = old.position,
    direction = old.direction,
    quality = stack.quality,
    force = old.force,
    fast_replace = true,
    spill = true,
    player = player,          -- излишки/старый предмет обрабатываются как при обычном fast-replace этим игроком
    create_build_effect_smoke = false,
    raise_built = true,
  }
  if new then
    new.mirroring = mirroring
    new.health = health
    -- перенесите свои данные из storage[old.unit_number] в storage[new.unit_number]
    storage.repellent_data[new.unit_number].frags = frags
  end

  stack.count = stack.count - 1 -- штатное размещение всё равно провалится по коллизии, тратим предмет сами

end