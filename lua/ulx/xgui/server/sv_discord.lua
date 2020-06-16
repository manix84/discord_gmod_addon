--painful file to create will all ttt cvars

local function init()
  --Preparation and post-round
  ULib.replicatedWritableCvar( "discordbot_endpoint", "rep_discordbot_endpoint", GetConVarNumber( "discordbot_endpoint" ), false, false, "xgui_gmsettings" )
  ULib.replicatedWritableCvar( "discordbot_name", "rep_discordbot_name", GetConVarNumber( "discordbot_name" ), false, false, "xgui_gmsettings" )
  ULib.replicatedWritableCvar( "discordbot_server_link", "rep_discordbot_server_link", GetConVarNumber( "discordbot_server_link" ), false, false, "xgui_gmsettings" )
  ULib.replicatedWritableCvar( "discordbot_mute_duration", "rep_discordbot_mute_duration", GetConVarNumber( "discordbot_mute_duration" ), false, false, "xgui_gmsettings" )
  ULib.replicatedWritableCvar( "discordbot_mute_round", "rep_discordbot_mute_round", GetConVarNumber( "discordbot_mute_round" ), false, false, "xgui_gmsettings" )
  ULib.replicatedWritableCvar( "discordbot_auto_connect", "rep_discordbot_auto_connect", GetConVarNumber( "discordbot_auto_connect" ), false, false, "xgui_gmsettings" )
end
xgui.addSVModule( "discordbot", init )