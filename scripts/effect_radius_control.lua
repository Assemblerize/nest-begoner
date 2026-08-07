function update_circle(circle_object, viewers)
  circle_object.players = viewers
  circle_object.visible = #viewers > 0
end

-- Show or hide circle for the player
function toggle_circles(event)
  begoner_log(false, true, "Toggling circles and flipping the boolean")

  local player_index = event.player_index
  local player = game.get_player(player_index)
  
  -- Flipping the boolean
  if is_viewer(player_index) then
    remove_viewer(player)
  else
    add_viewer(player)
  end
end

--Removing circle (not used)
function remove_circle(useful_id)
  local circle_object = storage.repellent_data[useful_id].circle
  if circle_object and circle_object.valid then
    begoner_log(false, true, "Removing a circle")
    circle_object.destroy()
  end
end

-- Helper to get an array for the rendering API
local function get_viewer_array()
  local viewers = {}
  for player_index, _ in pairs(storage.circle_viewer_index) do
    table.insert(viewers, player_index)
  end
  return viewers
end


-- Draw the circle on the map
function draw_circle(entity, radius)
  local viewers = get_viewer_array()
  return rendering.draw_circle{
    color = {0, 0.075, 0, 0.1},
    radius = radius,
    players = viewers,
    visible = #viewers > 0,
    filled = true,
    target = entity,
    surface = entity.surface,
    render_mode = "chart"
  }
end

-- Check if player is in the viewer array
function is_viewer(player_index)
  return storage.circle_viewer_index[player_index] == true
end

-- Add circle viewer
function add_viewer(player)
  if player and player.valid and not is_viewer(player.index) then
    storage.circle_viewer_index[player.index] = true
    player.set_shortcut_toggled("nbg-toggle-my-circles", true)
    updateAllCircles()
  end
end

-- Remove circle viewer
function remove_viewer(player)
  if player and player.valid and is_viewer(player.index)  then
    storage.circle_viewer_index[player.index] = nil
    player.set_shortcut_toggled("nbg-toggle-my-circles", false)
    updateAllCircles()
  else
    begoner_log(false, true, "The player is not a viewer or something is off in remove_viewer()!")
  end
end

function updateAllCircles()
  local viewers = get_viewer_array()
  begoner_log(false, true, "Updating circles. Number of viewers %d", #viewers)
  for _, data in pairs(storage.repellent_data) do
    local circle = data.circle
    if circle and circle.valid then
      update_circle(circle, viewers)
    end
  end
end