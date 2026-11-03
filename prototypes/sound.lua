local action_sound = {
  type = "sound",
  name = "nbg-repellent-action-sound",
  category = "weapon",
  filename = "__nest-begoner__/sound/action.ogg"
}

local charging_sound = {
  type = "sound",
  name = "nbg-repellent-charging-sound",
  category = "game-effect",
  filename = "__nest-begoner__/sound/charging.ogg"
}

local alert_sound = {
  type = "sound",
  name = "nbg-alert-sound",
  category = "alert",
  filename = "__core__/sound/message.ogg"
}

data:extend({action_sound, charging_sound, alert_sound})