-- GMod Discord Bot Server settings module for ULX GUI -- by Manxi84
--   A settings module for modifying server settings for GMod Discord Bot.

local discord = xlib.makepanel{ parent=xgui.null }

------------------------Discord Category Menu------------------------
discord.panel = xlib.makepanel{ x=160, y=5, w=415, h=318, parent=discord }
discord.catList = xlib.makelistview{ x=5, y=5, w=150, h=157, parent=discord }
discord.catList:AddColumn( "Discord Settings" )
discord.catList.Columns[1].DoClick = function() end

discord.catList.OnRowSelected = function( self, LineID, Line )
	local nPanel = xgui.modules.submodule[Line:GetValue(2)].panel
	if nPanel ~= discord.curPanel then
		nPanel:SetZPos( 0 )
		xlib.addToAnimQueue( "pnlSlide", { panel=nPanel, startx=-435, starty=0, endx=0, endy=0, setvisible=true } )
		if discord.curPanel then
			discord.curPanel:SetZPos( -1 )
			xlib.addToAnimQueue( discord.curPanel.SetVisible, discord.curPanel, false )
		end
		xlib.animQueue_start()
		discord.curPanel = nPanel
	else
		xlib.addToAnimQueue( "pnlSlide", { panel=nPanel, startx=0, starty=0, endx=-435, endy=0, setvisible=false } )
		self:ClearSelection()
		discord.curPanel = nil
		xlib.animQueue_start()
	end
	if nPanel.onOpen then nPanel.onOpen() end --If the panel has it, call a function when it's opened
end

--Process modular settings
function discord.processModules()
	discord.catList:Clear()
	for i, module in ipairs( xgui.modules.submodule ) do
		if module.mtype == "discord" and ( not module.access or LocalPlayer():query( module.access ) ) then
			local w,h = module.panel:GetSize()
			if w == h and h == 0 then module.panel:SetSize( 275, 322 ) end
			
			if module.panel.scroll then --For DListLayouts
				module.panel.scroll.panel = module.panel
				module.panel = module.panel.scroll
      end --if
			module.panel:SetParent( discord.panel )
			
			local line = discord.catList:AddLine( module.name, i )
			if ( module.panel == discord.curPanel ) then
				discord.curPanel = nil
				discord.catList:SelectItem( line )
			else
				module.panel:SetVisible( false )
      end --if
    end --if
  end --for
			end
discord.processModules()

xgui.hookEvent( "onProcessModules", nil, discord.processModules )
xgui.addSettingModule( "Discord", discord, "icon16/phone_sound.png" )

------------------------Settings Module-----------------------
local discord_settings_panel = xlib.makelistlayout{ w=415, h=318, parent=discord.panel }

--Mute Options
local discord_settings_mute_options_Category = vgui.Create( "DCollapsibleCategory", discord_settings_panel ) 
discord_settings_mute_options_Category:SetSize( 393, 45 )
discord_settings_mute_options_Category:SetExpanded( true )
discord_settings_mute_options_Category:SetLabel( "Mute Options" )

local discord_settings_mute_options_List = vgui.Create( "DPanelList", discord_settings_mute_options_Category )
discord_settings_mute_options_List:SetPos( 10, 25 )
discord_settings_mute_options_List:SetSize( 393, 45 )
discord_settings_mute_options_List:EnableVerticalScrollbar( false )
discord_settings_mute_options_List:SetSpacing( 5 )

local mute_round = xlib.makecheckbox{ x=0, y=0, label="Mute Until Round End", repconvar="rep_discordbot_mute_round", parent=discord_settings_mute_options_List }
discord_settings_mute_options_List.AddItem(mute_round)

local mute_duration = xlib.makeslider{ x=0, y=20, w=225, min=1, max=60, decimal=0, label="Mute Duration", repconvar="rep_discordbot_mute_duration", parent=discord_settings_mute_options_List }
function mute_round.OnChange()
  mute_duration:SetDisabled( mute_round:GetChecked() )
end
mute_duration:SetDisabled( mute_round:GetChecked() )

discord_settings_mute_options_List.AddItem(mute_duration)

--Config
local discord_settings_config_Category = vgui.Create( "DCollapsibleCategory", discord_settings_panel ) 
discord_settings_config_Category:SetSize( 393, 75 )
discord_settings_config_Category:SetExpanded( false )
discord_settings_config_Category:SetLabel( "Config" )

local discord_settings_config_List = vgui.Create( "DPanelList", discord_settings_config_Category )
discord_settings_config_List:SetPos( 10, 25 )
discord_settings_config_List:SetSize( 393, 75 )
discord_settings_config_List:EnableVerticalScrollbar( false )
discord_settings_config_List:SetSpacing( 5 )

discord_settings_config_List.AddItem(xlib.makelabel{ x=0, y=0, w=140, h=20, label="Message Prefix", parent=discord_settings_config_List })
discord_settings_config_List.AddItem(xlib.maketextbox{ x=150, y=0, w=243, h=20, label="Message Prefix", repconvar="rep_discordbot_name", parent=discord_settings_config_List })

discord_settings_config_List.AddItem(xlib.makelabel{ x=0, y=25, w=140, h=20, label="Discord Invitation Link", parent=discord_settings_config_List })
discord_settings_config_List.AddItem(xlib.maketextbox{ x=150, y=25, w=243, h=20, label="Discord Invitation Link", repconvar="rep_discordbot_server_link", parent=discord_settings_config_List })

discord_settings_config_List.AddItem(xlib.makecheckbox{ x=0, y=55, label="Attempt to connect Discord and Steam ID's Automatically", repconvar="rep_discordbot_auto_connect", parent=discord_settings_config_List })

--Bot Connection
local discord_botConnection_Category = vgui.Create( "DCollapsibleCategory", discord_settings_panel ) 
discord_botConnection_Category:SetSize( 393, 25 )
discord_botConnection_Category:SetExpanded( false )
discord_botConnection_Category:SetLabel( "Bot Connection (Don't Open On Stream!)" )

local discord_botConnection_List = vgui.Create( "DPanelList", discord_botConnection_Category )
discord_botConnection_List:SetPos( 10, 25 )
discord_botConnection_List:SetSize( 393, 25 )
discord_botConnection_List:EnableVerticalScrollbar( false )
discord_botConnection_List:SetSpacing( 5 )

discord_botConnection_List.AddItem(xlib.makelabel{ x=0, y=0, w=140, h=20, label="Node Bot Endpoint", parent=discord_botConnection_List })
discord_botConnection_List.AddItem(xlib.maketextbox{ x=150, y=0, w=243, h=20, label="Node Bot Endpoint", repconvar="rep_discordbot_endpoint", parent=discord_botConnection_List })

-- discord_botConnection_List.AddItem(xlib.makelabel{ x=0, y=25, w=140, h=20, label="Node Bot API-Key", parent=discord_botConnection_List })
-- discord_botConnection_List.AddItem(xlib.maketextbox{ x=150, y=25, w=243, h=20, label="Node Bot API-Key", repconvar="rep_discordbot_api_key", parent=discord_botConnection_List })

xgui.hookEvent( "onProcessModules", nil, discord_settings_panel.processModules )
xgui.addSubModule( "Settings", discord_settings_panel, nil, "discord" )

