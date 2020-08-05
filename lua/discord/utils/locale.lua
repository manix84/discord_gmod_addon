include('./logging.lua')

CreateConVar("discord_language", "english", 1, "Set the language you want user prompts to be in.")

local availableLanguages = {}
function getAvailableLanguages()
  if (table.Count(availableLanguages) <= 0) then
    local foundLocaleFiles, _ = file.Find('discord/locale/*.lua', 'lsv')
    for i, localeFileName in ipairs(foundLocaleFiles) do
      table.insert(availableLanguages, string.Replace(localeFileName, '.lua', ''))
    end
  end
  return availableLanguages
end
getAvailableLanguages()
print_debug("Available languages: ", util.TableToJSON(availableLanguages))

local selectedLanguage = 'english'
function getSelectedLanguage()
  local selectedLanguage = GetConVar("discord_language"):GetString()
  if (table.HasValue(getAvailableLanguages(), selectedLanguage)) then
    selectedLanguage = selectedLanguage
  end
  return selectedLanguage
end
getSelectedLanguage()
print_debug("Selected language: ", selectedLanguage)

local translationsCache = {}
local function getTranslationsCache()
  if (table.Count(translationsCache) <= 0) then
    print_debug('Caching language files:')
    local localesTable = getAvailableLanguages()
    for i, localeFileName in ipairs(localesTable) do
      translationsCache[localeFileName] = include('discord/locale/'..localeFileName..'.lua')
      print_debug('  -', 'discord/locale/'..localeFileName..'.lua')
    end
  end
  return translationsCache
end
getTranslationsCache()

local translations = {}
function getTranslations()
  local selectedLanguage = getSelectedLanguage()
  local translationsCache = getTranslationsCache()
  translations = translationsCache[selectedLanguage]
  return translations
end
getTranslations()
print_debug("Translations:", util.TableToJSON(translations, true))

util.AddNetworkString("discordAvailableLanguages")
util.AddNetworkString("request_discordAvailableLanguages")
net.Receive("request_discordAvailableLanguages", function( len, calling_ply )
  if (!calling_ply:IsSuperAdmin()) then
    return
  end
  local availableLanguages = getAvailableLanguages()
  local availableLanguagesJSON = util.TableToJSON(availableLanguages)
  local availableLanguagesCompressed = util.Compress(availableLanguagesJSON)

  net.Start("discordAvailableLanguages")
  net.WriteUInt(#availableLanguagesCompressed, 32)
  net.WriteData(availableLanguagesCompressed, #availableLanguagesCompressed)
  net.Send(calling_ply)
end)

util.AddNetworkString("discordSelectedLanguage")
util.AddNetworkString("request_discordSelectedLanguage")
net.Receive("request_discordSelectedLanguage", function( len, calling_ply )
  if (!calling_ply:IsSuperAdmin()) then
    return
  end
  local selectedLanguage = getSelectedLanguage()
  local selectedLanguageCompressed = util.Compress(selectedLanguage)

  net.Start("discordSelectedLanguage")
  net.WriteUInt(#selectedLanguageCompressed, 32)
  net.WriteData(selectedLanguageCompressed, #selectedLanguageCompressed)
  net.Send(calling_ply)
end)