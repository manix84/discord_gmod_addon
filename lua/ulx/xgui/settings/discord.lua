-- GMod Discord Bot Server settings module for ULX GUI -- by Manxi84
--   A settings module for modifying server settings for GMod Discord Bot.

local discord_settings = xlib.makepanel{ parent=xgui.null }

------------------------Discord Category Menu------------------------
discord_settings.panel = xlib.makepanel{ x=160, y=5, w=415, h=318, parent=discord_settings }
discord_settings.catList = xlib.makelistview{ x=5, y=5, w=150, h=157, parent=discord_settings }
discord_settings.catList:AddColumn( "Discord Settings" )
discord_settings.catList.Columns[1].DoClick = function() end

discord_settings.catList.OnRowSelected = function( self, LineID, Line )
	local nPanel = xgui.modules.submodule[Line:GetValue(2)].panel
	if nPanel ~= discord_settings.curPanel then
		nPanel:SetZPos( 0 )
		xlib.addToAnimQueue( "pnlSlide", { panel=nPanel, startx=-435, starty=0, endx=0, endy=0, setvisible=true } )
		if discord_settings.curPanel then
			discord_settings.curPanel:SetZPos( -1 )
			xlib.addToAnimQueue( discord_settings.curPanel.SetVisible, discord_settings.curPanel, false )
		end
		xlib.animQueue_start()
		discord_settings.curPanel = nPanel
	else
		xlib.addToAnimQueue( "pnlSlide", { panel=nPanel, startx=0, starty=0, endx=-435, endy=0, setvisible=false } )
		self:ClearSelection()
		discord_settings.curPanel = nil
		xlib.animQueue_start()
	end
	if nPanel.onOpen then nPanel.onOpen() end --If the panel has it, call a function when it's opened
end

--Process modular settings
function discord_settings.processModules()
	discord_settings.catList:Clear()
	for i, module in ipairs( xgui.modules.submodule ) do
		if module.mtype == "discord_settings" and ( not module.access or LocalPlayer():query( module.access ) ) then
			local w,h = module.panel:GetSize()
			if w == h and h == 0 then module.panel:SetSize( 275, 322 ) end
			
			if module.panel.scroll then --For DListLayouts
				module.panel.scroll.panel = module.panel
				module.panel = module.panel.scroll
			end
			module.panel:SetParent( discord_settings.panel )
			
			local line = discord_settings.catList:AddLine( module.name, i )
			if ( module.panel == discord_settings.curPanel ) then
				discord_settings.curPanel = nil
				discord_settings.catList:SelectItem( line )
			else
				module.panel:SetVisible( false )
			end
		end
	end
	discord_settings.catList:SortByColumn( 1, false )
end
discord_settings.processModules()

xgui.hookEvent( "onProcessModules", nil, discord_settings.processModules )
xgui.addSettingModule( "Discord", discord_settings, "icon16/phone_sound.png" )

-------------------------Admin Module-------------------------
local discord_panel = xlib.makelistlayout{ w=415, h=318, parent=discord_settings.panel }

--Mute Options
local discord_settings_admin_mute_options_Category = vgui.Create( "DCollapsibleCategory", discord_panel ) 
discord_settings_admin_mute_options_Category:SetSize( 380, 45 )
discord_settings_admin_mute_options_Category:SetExpanded( 1 )
discord_settings_admin_mute_options_Category:SetLabel( "Mute Options" )

local discord_settings_admin_mute_options_List = vgui.Create( "DPanelList", discord_settings_admin_mute_options_Category )
discord_settings_admin_mute_options_List:SetPos( 10, 25 )
discord_settings_admin_mute_options_List:SetSize( 380, 45 )
discord_settings_admin_mute_options_List:SetSpacing( 5 )

discord_settings_admin_mute_options_List.AddItem(xlib.makecheckbox{ x=0, y=0, label="Mute Until Round End", repconvar="rep_discordbot_mute_round", parent=discord_settings_admin_mute_options_List, textcolor=color_black })
discord_settings_admin_mute_options_List.AddItem(xlib.makeslider{ x=0, y=20, w=225, min=1, max=60, decimal=0, label="Mute Duration", repconvar="rep_discordbot_mute_duration", parent=discord_settings_admin_mute_options_List, textcolor=color_black })

--Settings
local discord_settings_admin_settings_Category = vgui.Create( "DCollapsibleCategory", discord_panel ) 
discord_settings_admin_settings_Category:SetSize( 380, 95 )
discord_settings_admin_settings_Category:SetExpanded( 0 )
discord_settings_admin_settings_Category:SetLabel( "Settings" )

local discord_settings_admin_settings_List = vgui.Create( "DPanelList", discord_settings_admin_settings_Category )
discord_settings_admin_settings_List:SetPos( 10, 25 )
discord_settings_admin_settings_List:SetSize( 380, 95 )
discord_settings_admin_settings_List:SetSpacing( 5 )

discord_settings_admin_settings_List.AddItem(xlib.makelabel{ x=0, y=0, w=140, h=20, label="Message Prefix", parent=discord_settings_admin_settings_List, textcolor=color_black })
discord_settings_admin_settings_List.AddItem(xlib.maketextbox{ x=150, y=0, w=230, h=20, label="Message Prefix", repconvar="rep_discordbot_name", parent=discord_settings_admin_settings_List, textcolor=color_black })

discord_settings_admin_settings_List.AddItem(xlib.makelabel{ x=0, y=25, w=140, h=20, label="Bot Endpoint", parent=discord_settings_admin_settings_List, textcolor=color_black })
discord_settings_admin_settings_List.AddItem(xlib.maketextbox{ x=150, y=25, w=230, h=20, label="Bot Endpoint", repconvar="rep_discordbot_endpoint", parent=discord_settings_admin_settings_List, textcolor=color_black })

discord_settings_admin_settings_List.AddItem(xlib.makelabel{ x=0, y=50, w=140, h=20, label="Discord Invitation Link", parent=discord_settings_admin_settings_List, textcolor=color_black })
discord_settings_admin_settings_List.AddItem(xlib.maketextbox{ x=150, y=50, w=230, h=20, label="Discord Invitation Link", repconvar="rep_discordbot_server_link", parent=discord_settings_admin_settings_List, textcolor=color_black })

discord_settings_admin_settings_List.AddItem(xlib.makecheckbox{ x=0, y=75, label="Attempt to connect Discord and Steam ID's Automatically", repconvar="rep_discordbot_auto_connect", parent=discord_settings_admin_settings_List, textcolor=color_black })


xgui.hookEvent( "onProcessModules", nil, discord_panel.processModules )
xgui.addSubModule( "Admin", discord_panel, nil, "discord_settings" )

