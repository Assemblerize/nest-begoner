local REPELLENT_RADIUS = settings.startup["nbg-min-radius-setting"].value or 224

function calculate_raduius_value(level)
  return REPELLENT_RADIUS * (1 + level * 0.1)
end

function begoner_log(forced, show_in_game, msg, ...)
  if settings.startup["nbg-debug-setting"].value or forced then
    local info = debug.getinfo(2, "S")
    local module_name = info and info.short_src or "unknown"
    local msg = string.format("[%s] " .. msg, module_name, ...)
    if show_in_game then
      game.print(msg, {skip = defines.print_skip.never})
    end
    helpers.write_file("begoner.txt", msg .. "\n", true)
  end
end

function print_undo(player)
  if player == nil or not player.valid then return end
  local stack = player.undo_redo_stack
  --undos
  for item_index = 1, stack.get_undo_item_count(), 1 do
    local item = stack.get_undo_item(item_index)
    if item ~= nil then
      for action_index, action in ipairs(item) do
        local target = action.target
        local type = action.type
        if target ~= nil then
          begoner_log(false, false, "Undo item #" .. item_index ..  ", type: " .. type .. " [Pos: " .. target.position.x .. " " .. target.position.y .. "] = " .. target.name)
        end
      end
    end
  end
end

function print_redo(player)
  if player == nil or not player.valid then return end
  local stack = player.undo_redo_stack
  --redos
  for item_index = 1, stack.get_redo_item_count(), 1 do
    local item = stack.get_redo_item(item_index)
    if item ~= nil then
      for action_index, action in ipairs(item) do
        local target = action.target
        local type = action.type
        if target ~= nil then
          begoner_log(false, false, "Redo item #" .. item_index ..  ", type: " .. type .. " [Pos: " .. target.position.x .. " " .. target.position.y .. "] = " .. target.name)
        end
      end
    end
  end
end

function debug_button()
  -- local surface = game.get_surface("nauvis")
  -- rendering.draw_sprite{
  --   sprite = "nbg-blank",
  --   render_layer = "object",
  --   target = {0, 0},
  --   surface = "nauvis"
  -- }
  -- rendering.draw_sprite{
  --   sprite = "nbg-blank",
  --   render_layer = "cargo-hatch",
  --   target = {0, 4},
  --   surface = "nauvis"
  -- }
  --   rendering.draw_sprite{
  --   sprite = "nbg-blank",
  --   render_layer = "object-under",
  --   target = {0, -4},
  --   surface = "nauvis"
  -- }
  --trigger_consequences(math.random(1000, 2000), 0, 0, 10, game.get_surface("nauvis"), game.forces["enemy"])
  -- begoner_log(false, false, "\n===============Undos:\n")
  -- print_undo(game.get_player(1))
  -- begoner_log(false, false, "\n+++++++++++++++Redos:\n")
  -- print_redo(game.get_player(1))
end