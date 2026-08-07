function blueprint_handling(event)
  begoner_log(false, true, "Handling blueprint")
  local player = game.players[event.player_index]
  
  -- Trying to get a special buffer item of the blueprint
  local blueprint = player.blueprint_to_setup

  -- If there isn't one, we check the regular item in hand (cursor_stack)
  if not (blueprint and blueprint.valid and blueprint.valid_for_read) then
    blueprint = player.cursor_stack
  end

  -- Now safely checking whether the item is a blueprint and whether it has data
  if blueprint and blueprint.valid and blueprint.valid_for_read and blueprint.is_blueprint then
    local entities = blueprint.get_blueprint_entities()
    if entities then
      local changed = false
      
      for _, ent in ipairs(entities) do
        if ent.name == "nbg-expansion-repellent" then
          begoner_log(false, true, "Changing repellent to holdable...")
          ent.name = "nbg-expansion-repellent-holdable"
          changed = true
        end
      end
      
      if changed then
        begoner_log(false, true, "Updating blueprint entities...")
        blueprint.set_blueprint_entities(entities)
      end
    end
  end
end