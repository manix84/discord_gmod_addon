local function init()
  --Preparation and post-round
  ULib.replicatedWritableCvar( "discordbot_endpoint", "rep_discordbot_endpoint", GetConVarNumber( "discordbot_endpoint" ), true, false, "xgui_gmsettings" )
  ULib.replicatedWritableCvar( "discordbot_name", "rep_discordbot_name", GetConVarNumber( "discordbot_name" ), true, true, "xgui_gmsettings" )
  ULib.replicatedWritableCvar( "discordbot_server_link", "rep_discordbot_server_link", GetConVarNumber( "discordbot_server_link" ), true, false, "xgui_gmsettings" )
  ULib.replicatedWritableCvar( "discordbot_mute_duration", "rep_discordbot_mute_duration", GetConVarNumber( "discordbot_mute_duration" ), true, true, "xgui_gmsettings" )
  ULib.replicatedWritableCvar( "discordbot_mute_round", "rep_discordbot_mute_round", GetConVarNumber( "discordbot_mute_round" ), true, true, "xgui_gmsettings" )
  ULib.replicatedWritableCvar( "discordbot_auto_connect", "rep_discordbot_auto_connect", GetConVarNumber( "discordbot_auto_connect" ), true, true, "xgui_gmsettings" )
end
xgui.addSVModule( "discordbot", init )