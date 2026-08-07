local ENERGY_TO_REPEL = 199000000

local begoner_log = begoner_log
local get_factorio_version = get_factorio_version
local renderAction = renderAction

local function add_custom_alert_to_force(entity)
  local sounded_players = {}
  local icon = {type = "virtual", name ="nbg-custom-alert-icon"}
  local message = {"locale.nbg-alert-low-power"}
  for _, player in pairs(entity.force.connected_players) do
    player.add_custom_alert(entity, icon, message, true)
    if not sounded_players[player] then
      player.play_sound({
        path = "nbg-alert-sound",
        volume_modifier = 1})
      sounded_players[player] = true
    end
  end
end

local function search_repellent(position)
  local failed_reppelents = {}
  for _, data_entry in pairs(storage.repellent_data) do
    local repellent = data_entry.entity
    -- Check only those repellents that exist and active (inactive nad discharged ones aren't supposed to see biters)
    if repellent.valid and repellent.active and data_entry.status ~= 1 then
      local dx = repellent.position.x - position.x
      local dy = repellent.position.y - position.y
      local dist_sq = dx * dx + dy * dy
      if dist_sq <= data_entry.radius * data_entry.radius then
        -- within the radius of effect
        if repellent.energy >=  ENERGY_TO_REPEL then
          -- enough energy to repel, return
          return "ready_to_repel", data_entry end
        table.insert(failed_reppelents, repellent)
      end
    end
  end
  if #failed_reppelents == 0 then return "none", failed_reppelents end
  return "failed_to_repel", failed_reppelents
end

local function up_the_frags(repellent_data)
  local frags = repellent_data.frags + 1
  repellent_data.frags = frags
  
  if get_factorio_version() ~= "2.0" then
    repellent_data.entity.set_tooltip_field({id = 555, name = {"custom-tooltip.nbg-frags"}, value = frags, order = 100})
  end
end

-- Main repel function
function repel_biters_function(event)
  begoner_log(false, true, "Repel event triggered...")

  if table_size(storage.repellent_data) == 0 then return end

  -- Test the biters
  local biter_group = event.group
  if not biter_group or not biter_group.valid then return end
  begoner_log(false, true, "Group valid")

  -- Search for a suitable repellent
  local result, data = search_repellent(biter_group.position)

  -- Process failures
  if result == "none" then
    begoner_log(false, true, "No repellent found within range!")
    return end

  if result == "failed_to_repel" then
    begoner_log(false, true, "Found only invalid repellents!")
    for i = 1, #data do
      add_custom_alert_to_force(data[i])
    end
    return end
  
  -- ready to go
  local repellent = data.entity
  change_biter_state(biter_group, repellent)
  repellent.energy = repellent.energy - ENERGY_TO_REPEL
  up_the_frags(data)
  begoner_log(false, true, "Biters repelled!")

  -- process direction for animation
  local ax, ay = repellent.position.x, repellent.position.y
  local bx, by = biter_group.position.x, biter_group.position.y
  renderAction(repellent, math.atan2(by - ay, bx - ax))

  -- sound effect for action
  repellent.surface.play_sound({
    path = "nbg-repellent-action-sound",
    position = repellent.position,
    volume_modifier = 1})


  begoner_log(false, true, "Repel event finished.")

  trigger_consequences(repellent.unit_number, repellent.position.x,
    repellent.position.y, data.radius, repellent.surface, biter_group.force, #biter_group.members)



end