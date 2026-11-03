local MAIN_ANIMATION_SPEED = 0.75
local MAIN_ANIMATION_SPEED_STOP = 0
local NO_CHARGE_ANIMATION_SPEED = 0.05

local begoner_log = begoner_log


--================Main animation speed changing================

local function changeRenderAnimationSpeed(render_object, new_speed)
  if not render_object then return end

  local current_speed = render_object.animation_speed
  local current_offset = render_object.animation_offset
  local current_tick = game.tick
  
  if current_speed == new_speed then return end

  local new_offset = (current_offset + current_tick * (current_speed - new_speed)) % 64

  render_object.animation_offset = new_offset
  render_object.animation_speed = new_speed
end

function setMainAnimationSpeed(animation_table, new_speed)
  for i = 1, #animation_table do
    if not animation_table[i] or not animation_table[i].valid then
      begoner_log(true, true, "Animation object is invalid or nil, skipping speed change.")
      return
    end
    changeRenderAnimationSpeed(animation_table[i], new_speed)
  end
end


--===================Animated elements================

local function renderAnimation(entity, animation_name, render_layer, time_to_live, speed, offset, tall)
  begoner_log(false, true, "Rendering %s animation for entity: %d", animation_name, entity.unit_number)
  return
    rendering.draw_animation{
      animation = animation_name,
      target = entity,
      surface = entity.surface,
      time_to_live = time_to_live,
      render_mode = "game",
      render_layer = render_layer,
      animation_speed = speed,
      animation_offset = offset,
      tall = tall
    }
end

function removeAnimation(animation_object)
  if not animation_object and not animation_object.valid then
    begoner_log(true, true, "Invalid animation, skipping remove...")
    return nil
  end
  animation_object.destroy()
  return nil
end

-- Screen
function renderWorkingScreenAnimation(entity, offset)
  return renderAnimation(entity, "nbg-working-screen-animation", "object", 0, MAIN_ANIMATION_SPEED, offset, false)
end

function renderNoChargeScreenAnimation(entity)
  return renderAnimation(entity, "nbg-no-charge-animation", "object", 0, NO_CHARGE_ANIMATION_SPEED, 0, false)
end

function swapScreenAnimation(screen_animation, to_working, offset)
  if not screen_animation and not screen_animation.valid then
    begoner_log(true, true, "Invalid screen animation!") return end
  begoner_log(false, true, "Swapping screen animation...")
  if to_working then
    screen_animation.animation = "nbg-working-screen-animation"
    screen_animation.animation_speed = MAIN_ANIMATION_SPEED
    screen_animation.animation_offset = offset
  else
    screen_animation.animation = "nbg-no-charge-animation" -- invalid check?
    screen_animation.animation_speed = NO_CHARGE_ANIMATION_SPEED
  end
end

--Charging
function renderChargingAnimation(entity, offset)
  return renderAnimation(entity, "nbg-charging-animation", "object", 0, MAIN_ANIMATION_SPEED, offset, false)
end

-- Main animation
function renderMainAnimation(entity)
  return { renderAnimation(entity, "nbg-repellent-animation-bottom", "object", 0, MAIN_ANIMATION_SPEED_STOP, 0, false),
           renderAnimation(entity, "nbg-repellent-animation-top", "above-inserters", 0, MAIN_ANIMATION_SPEED_STOP, 0, true) }
end


--Action
local function renderActionDirection(entity, animation)
  renderAnimation(entity, animation, "above-inserters", 16/MAIN_ANIMATION_SPEED, MAIN_ANIMATION_SPEED, -(game.tick * MAIN_ANIMATION_SPEED) % 16, true)
end


function renderAction(entity, direction)
  renderAnimation(entity, "nbg-fire-animation-base", "above-inserters", 16/MAIN_ANIMATION_SPEED, MAIN_ANIMATION_SPEED, -(game.tick * MAIN_ANIMATION_SPEED) % 16, false)

  local west_start = 2 * math.pi / 3

  if math.abs(direction) >= west_start then
    renderActionDirection(entity, "nbg-fire-animation-west")
  elseif direction >= 0 then
    renderActionDirection(entity, "nbg-fire-animation-south")
  else
    renderActionDirection(entity, "nbg-fire-animation-north")
  end
end



--================Static elements================


-- Indicator
function renderIndicator(entity)
  begoner_log(false, true, "Rendering indicator for entity: %d", entity.unit_number)
  return rendering.draw_sprite{
    sprite = "nbg-indicator",
    target = entity,
    surface = entity.surface,
    render_mode = "game",
    render_layer = "object",
    tint = {0, 0, 0, 0} -- by default entities have their status light turned off
  }
end