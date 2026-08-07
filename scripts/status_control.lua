local ENERGY_MIN = 0
local ENERGY_MAX = 200000000
local BOUNDARY_THRESHOLD = 1000000
local GROWTH_DEADBAND = 100000

local setMainAnimationSpeed = setMainAnimationSpeed
local renderChargingAnimation = renderChargingAnimation
local removeAnimation = removeAnimation
local renderWorkingScreenAnimation = renderWorkingScreenAnimation
local renderNoChargeScreenAnimation = renderNoChargeScreenAnimation
local swapScreenAnimation = swapScreenAnimation

local state_machine = require("__nest-begoner__.scripts.state_machine")

local smTransition = state_machine.transition
local smSetHandler = state_machine.setHandler


--===============Statuses================

local custom_status = {
  [1] = {
    diode = defines.entity_status_diode.red,
    label = { "entity-status.no-power" }
  },
  [2] = {
    diode = defines.entity_status_diode.yellow,
    label = { "entity-status.low-power" }
  },
  [3] = {
    diode = defines.entity_status_diode.green,
    label = { "entity-status.working" }
  },
  [4] = {
    diode = defines.entity_status_diode.yellow,
    label = { "entity-status.charging" }
  },
  [5] = {
    diode = defines.entity_status_diode.red,
    label = { "entity-status.disabled" }
  },
  [6] = {
    diode = defines.entity_status_diode.red,
    label = { "entity-status.marked-for-deconstruction" }
  },
  [7] = {
    diode = defines.entity_status_diode.red,
    label = { "entity-status.disabled-by-script" }
  }
}



-- Screen
smSetHandler("screen off", function(data_entry)
  data_entry.screen_animation = removeAnimation(data_entry.screen_animation)
end)

smSetHandler("low energy screen", function(data_entry)
  if data_entry.screen_animation then
    swapScreenAnimation(data_entry.screen_animation, false, nil)
  else
    data_entry.screen_animation = renderNoChargeScreenAnimation(data_entry.entity)
  end
end)

smSetHandler("working screen", function(data_entry)
  local animation_offset = data_entry.animation[1].animation_offset
  if data_entry.screen_animation then
    swapScreenAnimation(data_entry.screen_animation, true, animation_offset)
  else
    data_entry.screen_animation = renderWorkingScreenAnimation(data_entry.entity, animation_offset)
  end
end)


-- Indicator light
smSetHandler("red light", function(data_entry)
  data_entry.indicator.color = {0.8, 0, 0, 1}
end)

smSetHandler("yellow light", function(data_entry)
  data_entry.indicator.color = {0.8, 0.8, 0, 1}
end)

smSetHandler("green light", function(data_entry)
  data_entry.indicator.color = {0, 0.8, 0, 1}
end)


-- Animation speed
smSetHandler("anim speed 0", function(data_entry)
  setMainAnimationSpeed(data_entry.animation, 0)
end)

smSetHandler("anim speed max", function(data_entry)
  setMainAnimationSpeed(data_entry.animation, 0.75)
end)


-- Charging
smSetHandler("charging anim on", function(data_entry)
  data_entry.charging_animation = renderChargingAnimation(data_entry.entity, data_entry.animation[1].animation_offset)
end)

smSetHandler("charging anim off", function(data_entry)
  data_entry.charging_animation = removeAnimation(data_entry.charging_animation)
end)


-- Set status
local function setCustomStatus(entity, status)
  entity.custom_status = custom_status[status]
end



--================Status Compute===============

local function computeStatus(energy, last_energy, active, marked_for_deconstruction, disabled_by_script)
  --deactivated
  if active == false then
    if marked_for_deconstruction then
      return 6
    elseif disabled_by_script then
      return 7
    end
    return 5
  end

  --charging
  if last_energy ~= nil and (energy - last_energy) > GROWTH_DEADBAND then
    return 4
  end

  --normal operation
  if energy <= ENERGY_MIN + BOUNDARY_THRESHOLD then
    return 1
  elseif energy >= ENERGY_MAX - BOUNDARY_THRESHOLD then
    return 3
  else
    return 2
  end
end

function repellentStatusCheck(data_entry)

  if not data_entry or not data_entry.entity or not data_entry.entity.valid then
    return
  end

  local repellent = data_entry.entity
  local energy = repellent.energy
  local last_energy = data_entry.last_energy
  local old_status = data_entry.status

  local new_status = computeStatus(energy,
    last_energy,
    repellent.active,
    repellent.to_be_deconstructed(),
    repellent.disabled_by_script)

  data_entry.last_energy = energy

  if new_status == 4 then
    repellent.surface.play_sound({
      path = "nbg-repellent-charging-sound",
      position = repellent.position,
      volume_modifier = 1})
  end

  if new_status == old_status then return end

  data_entry.status = new_status
  setCustomStatus(data_entry.entity, new_status)
  smTransition(data_entry, old_status, new_status)

end

-- =============== Main Calls ================

function updateMarkedForDeconstructionStatus(event)
  if not storage.repellent_data then return end
  repellentStatusCheck(storage.repellent_data[event.entity.unit_number])
end

-- switching animation when has power
function updateAllRepellentStatuses()
  if not storage.repellent_data then return end

   for _, data_entry in pairs(storage.repellent_data) do
    repellentStatusCheck(data_entry)
  end
end
