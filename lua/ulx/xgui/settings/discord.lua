--GMod Discord Bot Server settings module for ULX GUI -- by Manxi84
--  A settings module for modifying server settings for GMod Discord Bot.

local FILEPATH = "gmod_discord_bot.dat"
local ids = {}

ids_raw = file.Read( FILEPATH, "DATA" )
if (ids_raw) then
  ids = util.JSONToTable(ids_raw)
end

function saveIDs()
  file.Write( FILEPATH, util.TableToJSON(ids))
end

local discordbot_settings = {}

discordbot_settings.main = xlib.makepanel{ parent=xgui.null }

------------------------Discord Category Menu------------------------
discordbot_settings.main.catList = xlib.makelistview{ x=5, y=5, w=150, h=157, parent=discordbot_settings.main }
discordbot_settings.main.catList:AddColumn( "Discord Settings" )
discordbot_settings.main.catList.Columns[1].DoClick = function() end

--------------------------GMOD Settings--------------------------
discordbot_settings.main.panel = xlib.makepanel{ x=160, y=5, w=420, h=318, parent=discordbot_settings.main }


xlib.makelabel{ x=170, y=10, w=140, h=20, label="Message Prefix", parent=discordbot_settings.main, textcolor=color_black }
xlib.maketextbox{ x=320, y=10, w=250, h=20, label="Message Prefix", repconvar="rep_discordbot_name", parent=discordbot_settings.main, textcolor=color_black }

xlib.makelabel{ x=170, y=35, w=140, h=20, label="Bot Endpoint", parent=discordbot_settings.main, textcolor=color_black }
xlib.maketextbox{ x=320, y=35, w=250, h=20, label="Bot Endpoint", repconvar="rep_discordbot_endpoint", parent=discordbot_settings.main, textcolor=color_black }

xlib.makelabel{ x=170, y=60, w=140, h=20, label="Discord Invitation Link", parent=discordbot_settings.main, textcolor=color_black }
xlib.maketextbox{ x=320, y=60, w=250, h=20, label="Discord Invitation Link", repconvar="rep_discordbot_server_link", parent=discordbot_settings.main, textcolor=color_black }

xlib.makecheckbox{ x=170, y=90, label="Attempt to connect Discord and Steam ID's Automatically", repconvar="rep_discordbot_auto_connect", parent=discordbot_settings.main, textcolor=color_black }

xlib.makecheckbox{ x=170, y=175, label="Mute Until Round End", repconvar="rep_discordbot_mute_round", parent=discordbot_settings.main, textcolor=color_black }
xlib.makeslider{ x=170, y=195, w=225, min=1, max=60, decimal=0, label="Mute Duration", repconvar="rep_discordbot_mute_duration", parent=discordbot_settings.main, textcolor=color_black }

-- discordbot_settings.main.mask = xlib.makepanel{ x=295, y=5, w=290, h=322, parent=discordbot_settings.main }
-- discordbot_settings.main.panel = xlib.makepanel{ x=5, w=285, h=322, parent=discordbot_settings.main.mask }



--------------------Admin-related Module--------------------
local arpnl = xlib.makelistlayout{ w=415, h=318, parent=xgui.null }

local arclp = vgui.Create( "DCollapsibleCategory", arpnl ) 
arclp:SetSize( 390, 120)
arclp:SetExpanded( 1 )
arclp:SetLabel( "Admin-related" )

local arlst = vgui.Create( "DPanelList", arclp )
arlst:SetPos( 5, 25 )
arlst:SetSize( 390, 120 )
arlst:SetSpacing( 5 )

local aril = xlib.makeslider{label="ttt_idle_limit (def. 180)", min=50, max=300, repconvar="rep_ttt_idle_limit", parent=arlst }
arlst:AddItem( aril )

local arnck = xlib.makecheckbox{label="ttt_namechange_kick (def. 1)", repconvar="rep_ttt_namechange_kick", parent=arlst }
arlst:AddItem( arnck )

local arncbt = xlib.makeslider{label="ttt_namechange_bantime (def. 10)", min=0, max=60, repconvar="rep_ttt_namechange_bantime", parent=arlst }
arlst:AddItem( arncbt )

xgui.hookEvent( "onProcessModules", nil, arpnl.processModules )
xgui.addSubModule( "Admin-related", arpnl, nil, discordbot_settings.main )

-- discordbot_settings.main.mask = xlib.makepanel{ x=295, y=5, w=290, h=322, parent=discordbot_settings.main }
-- discordbot_settings.main.panel = xlib.makepanel{ x=5, w=285, h=322, parent=discordbot_settings.main.mask }



xgui.addSettingModule( "Discord", discordbot_settings.main, "icon16/phone_sound.png" )
