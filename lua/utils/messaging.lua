include('./locale.lua')

function playerMessage(translation_key, target_ply, ...)
  local translations = getTranslations()
  local translation_string = translations[translation_key] or ''
  local message = string.format(translation_string, ...)
  target_ply:PrintMessage(HUD_PRINTTALK, "["..GetConVar("discord_name"):GetString().."] " .. message)
end

function announceMessage(translation_key, ...)
  local translations = getTranslations()
  local translation_string = translations[translation_key] or ''
  local message = string.format(translation_string, ...)
  PrintMessage(HUD_PRINTTALK, "["..GetConVar("discord_name"):GetString().."] " .. message)
end