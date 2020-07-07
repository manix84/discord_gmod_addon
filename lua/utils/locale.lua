include('./logging.lua')

CreateConVar("discord_language", "english", 1, "Set the language you want user prompts to be in.")

local availableLanguages = {}
function getAvailableLanguages()
  if (table.Count(availableLanguages) <= 0) then
    local foundLocaleFiles, _ = file.Find('locale/*.lua', 'lsv')
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

local translations = {}
function getTranslations()
  local selectedLanguage = getSelectedLanguage();
  translations = include('locale/'..selectedLanguage..'.lua')
  return translations
end
getTranslations()
print_debug("Translations:", util.TableToJSON(translations, true))

