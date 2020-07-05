local function init()
  --Preparation and post-round
  ULib.replicatedWritableCvar( "discord_endpoint", "rep_discord_endpoint", GetConVarNumber( "discord_endpoint" ), true, false, "xgui_gmsettings" )
  ULib.replicatedWritableCvar( "discord_name", "rep_discord_name", GetConVarNumber( "discord_name" ), true, true, "xgui_gmsettings" )
  ULib.replicatedWritableCvar( "discord_server_link", "rep_discord_server_link", GetConVarNumber( "discord_server_link" ), true, false, "xgui_gmsettings" )
  ULib.replicatedWritableCvar( "discord_mute_duration", "rep_discord_mute_duration", GetConVarNumber( "discord_mute_duration" ), true, true, "xgui_gmsettings" )
  ULib.replicatedWritableCvar( "discord_mute_round", "rep_discord_mute_round", GetConVarNumber( "discord_mute_round" ), true, true, "xgui_gmsettings" )
  ULib.replicatedWritableCvar( "discord_auto_connect", "rep_discord_auto_connect", GetConVarNumber( "discord_auto_connect" ), true, true, "xgui_gmsettings" )
end
xgui.addSVModule( "discordbot", init )