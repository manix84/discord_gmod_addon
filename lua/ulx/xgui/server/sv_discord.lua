local function init()
  --Preparation and post-round
  ULib.replicatedWritableCvar("discord_endpoint", "rep_discord_endpoint", GetConVar("discord_endpoint"), true, false, "xgui_gmsettings");
  ULib.replicatedWritableCvar("discord_api_key", "rep_discord_api_key", GetConVar("discord_api_key"), true, false, "xgui_gmsettings");
  ULib.replicatedWritableCvar("discord_name", "rep_discord_name", GetConVar("discord_name"), true, true, "xgui_gmsettings");
  ULib.replicatedWritableCvar("discord_server_link", "rep_discord_server_link", GetConVar("discord_server_link"), true, false, "xgui_gmsettings");
  ULib.replicatedWritableCvar("discord_mute_duration", "rep_discord_mute_duration", GetConVar("discord_mute_duration"), true, true, "xgui_gmsettings");
  ULib.replicatedWritableCvar("discord_mute_round", "rep_discord_mute_round", GetConVar("discord_mute_round"), true, true, "xgui_gmsettings");
  ULib.replicatedWritableCvar("discord_auto_connect", "rep_discord_auto_connect", GetConVar("discord_auto_connect"), true, true, "xgui_gmsettings");
  ULib.replicatedWritableCvar("discord_debug", "rep_discord_debug", GetConVar("discord_debug"), true, true, "xgui_gmsettings");
  ULib.replicatedWritableCvar("discord_language", "rep_discord_language", GetConVar("discord_language"), true, true, "xgui_gmsettings");
  util.AddNetworkString("connectDiscordID");
  util.AddNetworkString("discordSelectedLanguage");
  util.AddNetworkString("request_discordSelectedLanguage");
  util.AddNetworkString("discordAvailableLanguages");
  util.AddNetworkString("request_discordAvailableLanguages");
  util.AddNetworkString("discordTestConnection");
  util.AddNetworkString("request_discordTestConnection");
  util.AddNetworkString("discordPlayerTable");
  util.AddNetworkString("request_discordPlayerTable");
  util.AddNetworkString("addonVersion");
  util.AddNetworkString("request_addonVersion");
  util.AddNetworkString("botVersion");
  util.AddNetworkString("request_botVersion");
  resource.AddSingleFile("materials/icon128/discord_muter.png");
  resource.AddSingleFile("materials/icon16/discord_muter.png");
end

xgui.addSVModule("discord", init);
