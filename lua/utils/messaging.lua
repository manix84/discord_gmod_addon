include('./logging.lua')

CreateConVar("discord_language", "eng", 1, "Set the language you want user prompts to be in.")

local setLanguage = GetConVar("discord_language"):GetString()
print_debug("Language Set: ", setLanguage)

local translations = include('locale/english.lua')
print_debug("Translation strings:", util.TableToJSON(translations, true))

function playerMessage(translation_key, target_ply, ...)
  local translation_string = translations[translation_key] or ''
  local message = string.format(translation_string, ...)
  target_ply:PrintMessage(HUD_PRINTTALK, "["..GetConVar("discord_name"):GetString().."] " .. message)
end

function announceMessage(translation_key, ...)
  local translation_string = translations[translation_key] or ''
  local message = string.format(translation_string, ...)
  PrintMessage(HUD_PRINTTALK, "["..GetConVar("discord_name"):GetString().."] " .. message)
end