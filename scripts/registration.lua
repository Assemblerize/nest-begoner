local begoner_log = begoner_log
local draw_circle = draw_circle
local renderMainAnimation = renderMainAnimation
local renderIndicator = renderIndicator
local repellentStatusCheck = repellentStatusCheck
local calculate_raduius_value = calculate_raduius_value

-- Register repellent_entity
function register_repellent(event)
  begoner_log(false, true, "Registering repellent... Source: %d", event.name)
  local entity = event.entity
  
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