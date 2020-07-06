function playerMessage(translation_string, target_ply, ...)
  local message = string.format(translation_string, ...)
  target_ply:PrintMessage(HUD_PRINTTALK, "["..GetConVar("discord_name"):GetString().."] " .. message)
end

function announceMessage(translation_string, ...)
  local message = string.format(translation_string, ...)
  PrintMessage(HUD_PRINTTALK, "["..GetConVar("discord_name"):GetString().."] " .. message)
end