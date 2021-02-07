AddCSLuaFile("utils/logging.lua")
-- Discord Bot Server settings module for ULX GUI -- by Manxi84
--   A settings module for modifying server settings for Discord Bot.

local discord = xlib.makepanel{ parent = xgui.null }

------------------------Discord Category Menu------------------------
discord.panel = xlib.makepanel{
  x = 160, y = 5,
  w = 415, h = 318,
  parent = discord
}
discord.catList = xlib.makelistview{
  x = 5, y = 5,
  w = 150, h = 157,
  parent = discord
}
discord.catList:AddColumn( "Discord Settings" )
discord.catList.Columns[1].DoClick = function() end

discord.catList.OnRowSelected = function( self, LineID, Line )
  local nPanel = xgui.modules.submodule[Line:GetValue(2)].panel
  if nPanel ~=  discord.curPanel then
    nPanel:SetZPos( 0 )
    xlib.addToAnimQueue( "pnlSlide", { panel = nPanel, startx = -435, starty = 0, endx = 0, endy = 0, setvisible = true } )
    if discord.curPanel then
      discord.curPanel:SetZPos( -1 )
      xlib.addToAnimQueue( discord.curPanel.SetVisible, discord.curPanel, false )
    end
    xlib.animQueue_start()
    discord.curPanel = nPanel
  else
    xlib.addToAnimQueue( "pnlSlide", { panel = nPanel, startx = 0, starty = 0, endx = -435, endy = 0, setvisible = false } )
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
local discord_settings_panel = xlib.makelistlayout{ w = 415, h = 318, parent = discord.panel }

xlib.makelabel{
  x = 5, y = 0,
  w = 425, h = 20,
  label = "These settings do not save when the server changes maps, is restarted, or crashes.",
  parent = discord_settings_panel
}

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

local mute_round = xlib.makecheckbox{
  x = 0, y = 0,
  label = "Mute Until Round End",
  repconvar = "rep_discord_mute_round",
  parent = discord_settings_mute_options_List
}
discord_settings_mute_options_List.AddItem(mute_round)

local mute_duration = xlib.makeslider{
  x = 0, y = 20,
  w = 225,
  min = 1, max = 60,
  decimal = 0,
  label = "Mute Duration",
  repconvar = "rep_discord_mute_duration",
  parent = discord_settings_mute_options_List
  }
function mute_round.OnChange()
  mute_duration:SetDisabled( mute_round:GetChecked() )
end
mute_duration:SetDisabled( mute_round:GetChecked() )

discord_settings_mute_options_List.AddItem(mute_duration)

--Config
local discord_settings_config_Category = vgui.Create( "DCollapsibleCategory", discord_settings_panel )
discord_settings_config_Category:SetSize( 393, 115 )
discord_settings_config_Category:SetExpanded( true )
discord_settings_config_Category:SetLabel( "Config" )

local discord_settings_config_List = vgui.Create( "DPanelList", discord_settings_config_Category )
discord_settings_config_List:SetPos( 10, 25 )
discord_settings_config_List:SetSize( 393, 115 )
discord_settings_config_List:EnableVerticalScrollbar( false )
discord_settings_config_List:SetSpacing( 5 )

discord_settings_config_List.AddItem(xlib.makelabel{
  x = 0, y = 0,
  w = 140, h = 20,
  label = "Message Prefix",
  parent = discord_settings_config_List
})
discord_settings_config_List.AddItem(xlib.maketextbox{
  x = 150, y = 0,
  w = 233, h = 20,
  label = "Message Prefix",
  repconvar = "rep_discord_name",
  parent = discord_settings_config_List
})

discord_settings_config_List.AddItem(xlib.makelabel{
  x = 0, y = 25,
  w = 140, h = 20,
  label = "Discord Invitation Link",
  parent = discord_settings_config_List
})
discord_settings_config_List.AddItem(xlib.maketextbox{
  x = 150, y = 25,
  w = 233, h = 20,
  label = "Discord Invitation Link",
  repconvar = "rep_discord_server_link",
  parent = discord_settings_config_List
})

local selectedLanguageKey = ""

net.Receive("discordSelectedLanguage", function()
  local len = net.ReadUInt(32)
  local selectedLanguageCompressed = net.ReadData(len)
  selectedLanguageKey = util.Decompress(selectedLanguageCompressed)
end)
local function get_selectedLanguage()
  net.Start("request_discordSelectedLanguage")
  net.SendToServer()
end
get_selectedLanguage()

-- Coming soon! The combobox isn't working yet, so i've disabled it for now.
discord_settings_config_List.AddItem(xlib.makelabel{
  x = 0, y = 50,
  h = 20,
  label = "Set Language",
  parent = discord_settings_config_List
})
local discord_settings_config_Language_combobox = xlib.makecombobox{
  x = 150, y = 50,
  w = 233,
  parent = discord_settings_config_List
}
discord_settings_config_Language_combobox:SetDisabled(true)
discord_settings_config_List.AddItem(discord_settings_config_Language_combobox)
discord_settings_config_Language_combobox.OnSelect = function( self, index, value, data )
  RunConsoleCommand("rep_discord_language", tostring(data))
  get_selectedLanguage()
end

net.Receive("discordAvailableLanguages", function()
  local len = net.ReadUInt(32)
  local availableLanguagesCompressed = net.ReadData(len)
  local availableLanguagesJSON = util.Decompress(availableLanguagesCompressed)

  availableLanguagesTable = util.JSONToTable(availableLanguagesJSON)

  discord_settings_config_Language_combobox:Clear()
  for i, languageName in ipairs(availableLanguagesTable) do
    local languageTitle = string.upper(string.sub(languageName, 1, 1)) .. string.lower(string.sub(languageName, 2))
    local isSelected = (languageName == selectedLanguageKey)
    discord_settings_config_Language_combobox:AddChoice(
      languageTitle,
      languageName,
      isSelected
    )
    discord_settings_config_Language_combobox:SetDisabled( i <=  1 )
  end
end)
local function get_availableLanguages()
  net.Start("request_discordAvailableLanguages")
  net.SendToServer()
end
get_availableLanguages()

discord_settings_config_List.AddItem(xlib.makecheckbox{
  x = 0, y = 75,
  label = "Attempt to connect Discord and Steam Names automatically.",
  repconvar = "rep_discord_auto_connect",
  parent = discord_settings_config_List
})

discord_settings_config_List.AddItem(xlib.makecheckbox{
  x = 0, y = 95,
  label = "Enable debug messages to console.",
  repconvar = "rep_discord_debug",
  parent = discord_settings_config_List
})

--Bot Connection
local discord_botConnection_Category = vgui.Create( "DCollapsibleCategory", discord_settings_panel )
discord_botConnection_Category:SetSize( 393, 25 )
discord_botConnection_Category:SetExpanded( false )
discord_botConnection_Category:SetLabel( "Bot Connection (Don't Open On Stream!)" )

local discord_botConnection_List = vgui.Create( "DPanelList", discord_botConnection_Category )
discord_botConnection_List:SetPos( 10, 25 )
discord_botConnection_List:SetSize( 393, 90 )
discord_botConnection_List:EnableVerticalScrollbar( false )
discord_botConnection_List:SetSpacing( 5 )

discord_botConnection_List.AddItem(xlib.makelabel{
  x = 0, y = 0,
  w = 140, h = 20,
  label = "Node Bot Endpoint",
  parent = discord_botConnection_List
})
discord_botConnection_List.AddItem(xlib.maketextbox{
  x = 150, y = 0,
  w = 233, h = 20,
  label = "Node Bot Endpoint",
  repconvar = "rep_discord_endpoint",
  parent = discord_botConnection_List
})

discord_botConnection_List.AddItem(xlib.makelabel{
  x = 0, y = 25,
  w = 140, h = 20,
  label = "Node Bot API-Key",
  parent = discord_botConnection_List
})
discord_botConnection_List.AddItem(xlib.maketextbox{
  x = 150, y = 25,
  w = 233, h = 20,
  label = "Node Bot API-Key",
  repconvar = "rep_discord_api_key",
  parent = discord_botConnection_List
})
local discord_botConnection_testButton_host_result = xlib.makelabel{
  x = 135, y = 0,
  w = 20, h = 20,
  label = "",
  parent = discord_botConnection_List
}
local discord_botConnection_testButton_api_key_result = xlib.makelabel{
  x = 135, y = 25,
  w = 20, h = 20,
  label = "",
  parent = discord_botConnection_List
}
discord_botConnection_List.AddItem(discord_botConnection_testButton_host_result)
discord_botConnection_List.AddItem(discord_botConnection_testButton_api_key_result)
local discord_botConnection_testButton = xlib.makebutton{
  x = 293, y = 50,
  w = 90,
  label = "Test Connection",
  parent = discord_botConnection_List
}
discord_botConnection_testButton.DoClick = function()
  discord_botConnection_testButton__ExecuteTest()
end
discord_botConnection_List.AddItem(discord_botConnection_testButton)

timer.Create("clearTestResponse", 5.0, 0, function()
  discord_botConnection_testButton_host_result:SetText("")
  discord_botConnection_testButton_api_key_result:SetText("")
end)

net.Receive("discordTestConnection", function()
  local len = net.ReadUInt(32)
  local compressedConnectionTestResponse = net.ReadData(len)
  local connectionTestResponseJSON = util.Decompress(compressedConnectionTestResponse)
  local connectionTestResponseTable = util.JSONToTable(connectionTestResponseJSON)

  timer.Stop("clearTestResponse")
  timer.Start("clearTestResponse")

  if (connectionTestResponseTable["success"]) then
    discord_botConnection_testButton_host_result:SetTextColor( Color( 0, 200, 0) )
    discord_botConnection_testButton_host_result:SetText("✔")
    discord_botConnection_testButton_api_key_result:SetTextColor( Color( 0, 200, 0) )
    discord_botConnection_testButton_api_key_result:SetText("✔")
  elseif (connectionTestResponseTable["errorId"] == "HOST_MISSCONFIGURED") then
    discord_botConnection_testButton_host_result:SetTextColor( Color( 255, 0, 0) )
    discord_botConnection_testButton_host_result:SetText("✘")
    -- discord_botConnection_testButton_api_key_result:SetTextColor( Color( 0, 0, 0) )
    -- discord_botConnection_testButton_api_key_result:SetText("?")
  elseif (connectionTestResponseTable["errorId"] == "AUTHORIZATION_MISSMATCH") then
    discord_botConnection_testButton_host_result:SetTextColor( Color( 0, 200, 0) )
    discord_botConnection_testButton_host_result:SetText("✔")
    discord_botConnection_testButton_api_key_result:SetTextColor( Color( 255, 0, 0) )
    discord_botConnection_testButton_api_key_result:SetText("✘")
  end
end)
function discord_botConnection_testButton__ExecuteTest()
  net.Start("request_discordTestConnection")
  net.SendToServer()
end

xgui.hookEvent( "onProcessModules", nil, discord_settings_panel.processModules )
xgui.addSubModule( "Settings", discord_settings_panel, nil, "discord" )


-------------------------Players Module-----------------------
local discord_playerConnections_panel = xlib.makelistlayout{ w = 415, h = 318, parent = discord.panel }

local steamIDToDiscordIDConnectionTable = {}

--Player Connection
local discord_playerConnections_table_Category = vgui.Create( "DCollapsibleCategory", discord_playerConnections_panel )
discord_playerConnections_table_Category:SetSize( 393, 45 )
discord_playerConnections_table_Category:SetExpanded( true )
discord_playerConnections_table_Category:SetLabel( "Player Connections" )

local discord_playerConnections_table_List = vgui.Create( "DPanelList", discord_playerConnections_table_Category )
discord_playerConnections_table_List:SetPos( 10, 25 )
discord_playerConnections_table_List:SetSize( 393, 290 )
discord_playerConnections_table_List:EnableVerticalScrollbar( false )
discord_playerConnections_table_List:SetSpacing( 5 )

discord_playerConnections_table_List.listview = xlib.makelistview{
  x = 0, y = 5,
  w = 393, h = 250,
  parent = discord_playerConnections_table_List
}
discord_playerConnections_table_List.listview:AddColumn( "Name" )
-- discord_playerConnections_table_List.listview.Columns[1]:set
discord_playerConnections_table_List.listview:AddColumn( "Role" )
discord_playerConnections_table_List.listview:AddColumn( "DiscordID" )


discord_playerConnections_table_List.AddItem(xlib.makelabel{
  x = 0, y = 265,
  w = 80, h = 20,
  label = "Player DiscordID",
  parent = discord_playerConnections_table_List
})
local discord_playerConnections_DiscordID_textBox = xlib.maketextbox{
  x = 85, y = 265,
  w = 185, h = 20,
  label = "",
  disabled = true,
  parent = discord_playerConnections_table_List
}
discord_playerConnections_table_List.AddItem(discord_playerConnections_DiscordID_textBox)

local discord_playerConnections_table_List__Selected_SteamID = nil

local discord_playerConnections_DiscordID_saveButton = xlib.makebutton{
  x = 275, y = 265,
  w = 38,
  label = "Save",
  disabled = true,
  parent = discord_playerConnections_table_List
}

local saveDiscordSteamConnection = function()
  local target_ply = player.GetBySteamID(discord_playerConnections_table_List__Selected_SteamID);
  local discord_id = discord_playerConnections_DiscordID_textBox:GetText();

  net.Start("connectDiscordID")
  net.WriteEntity(target_ply)
  net.WriteString(discord_id)
  net.SendToServer()
  discord_playerConnections_DiscordID_textBox:SetText('')
  discord_playerConnections_DiscordID_textBox:SetDisabled( true )
  discord_playerConnections_DiscordID_saveButton:SetDisabled( true )
  discord_playerConnections_table_List__Refresh()
end
discord_playerConnections_DiscordID_saveButton.DoClick = saveDiscordSteamConnection
discord_playerConnections_DiscordID_textBox.OnEnter = saveDiscordSteamConnection
discord_playerConnections_table_List.AddItem(discord_playerConnections_DiscordID_saveButton)

local discord_playerConnections_refreshButton = xlib.makebutton{
  x = 317, y = 265,
  w = 75,
  label = "Refresh List",
  parent = discord_playerConnections_table_List
}
discord_playerConnections_refreshButton.DoClick = function()
  discord_playerConnections_table_List__Refresh()
  discord_playerConnections_table_List__Selected_SteamID = nil
  discord_playerConnections_DiscordID_textBox:SetDisabled( true )
  discord_playerConnections_DiscordID_saveButton:SetDisabled( true )
  discord_playerConnections_DiscordID_textBox:SetText('')
end
discord_playerConnections_table_List.AddItem(discord_playerConnections_refreshButton)
discord_playerConnections_table_List.listview.OnRowSelected = function( self, LineID, Line )
  discord_playerConnections_table_List__Selected_SteamID = Line:GetValue( 4 )
  discord_playerConnections_DiscordID_textBox:SetDisabled( false )
  discord_playerConnections_DiscordID_saveButton:SetDisabled( false )
  discord_playerConnections_DiscordID_textBox:SetText(
    steamIDToDiscordIDConnectionTable[discord_playerConnections_table_List__Selected_SteamID] or ''
  )
end

net.Receive("discordPlayerTable", function()
  local len = net.ReadUInt(32)
  local compressedSteamIDToDiscordIDConnection = net.ReadData(len)
  local steamIDToDiscordIDConnectionJSON = util.Decompress(compressedSteamIDToDiscordIDConnection)

  steamIDToDiscordIDConnectionTable = util.JSONToTable(steamIDToDiscordIDConnectionJSON)

  discord_playerConnections_table_List.listview:Clear()
  for index, target_ply in pairs(player.GetAll()) do
    if not target_ply:IsBot() then
      discord_playerConnections_table_List.listview:AddLine(
        target_ply:GetName(),
        target_ply:GetUserGroup(),
        steamIDToDiscordIDConnectionTable[target_ply:SteamID()],
        target_ply:SteamID() -- Hidden SteamID column
      )
    end
  end
end)
function discord_playerConnections_table_List__Refresh()
  net.Start("request_discordPlayerTable")
  net.SendToServer()
end
discord_playerConnections_table_List__Refresh()

xgui.hookEvent( "onProcessModules", nil, discord_playerConnections_panel.processModules )
xgui.addSubModule( "Player Connections", discord_playerConnections_panel, nil, "discord" )


-------------------------About Module-----------------------
local discord_about_panel = xlib.makelistlayout{
  w = 415, h = 318,
  parent = discord.panel
}

--About
local discord_about_table_Category = vgui.Create( "DCollapsibleCategory", discord_about_panel )
discord_about_table_Category:SetSize( 393, 45 )
discord_about_table_Category:SetExpanded( true )
discord_about_table_Category:SetLabel( "About" )

-- Discord Muter Icon
local discord_about_table_about_icon = vgui.Create("DImage", discord_about_table_Category) -- Add image to Category
discord_about_table_about_icon:SetPos(133, 25) -- Move it into Category
discord_about_table_about_icon:SetSize(128, 128) -- Size it to 128x128

-- Set material relative to "garrysmod/materials/"
discord_about_table_about_icon:SetImage("icon128/discord_muter.png")

xlib.makelabel{
  x = 145, y = 153,
  w = 128, h = 20,
  label = "Discord Muter",
  font = "DefaultLarge",
  parent = discord_about_table_Category
}
local addon_version = xlib.makelabel{
  x = 227, y = 153,
  w = 40, h = 20,
  label = "...",
  font = "DefaultLarge",
  parent = discord_about_table_Category
}
xlib.makelabel{
  x = 137, y = 170,
  w = 128, h = 20,
  label = "by Rob \"Manix84\" Taylor",
  parent = discord_about_table_Category
}
xlib.makelabel{
  x = 152, y = 185,
  w = 100, h = 20,
  label = "Bot Version:",
  parent = discord_about_table_Category
}
local bot_version = xlib.makelabel{
  x = 211, y = 185,
  w = 40, h = 20,
  label = "...",
  parent = discord_about_table_Category
}
-- xlib.makelabel{
--   x = 5, y = 210,
--   w = 100, h = 20,
--   label = "Addon Source Code",
--   parent = discord_about_table_Category
-- }

-- xlib.makelabel{
--   x = 7, y = 225,
--   w = 100, h = 20,
--   label = "Bot Source Code",
--   parent = discord_about_table_Category
-- }

net.Receive("addonVersion", function()
  local len = net.ReadUInt(32)
  local compressedAddonVersion = net.ReadData(len)
  local addonVersion = util.Decompress(compressedAddonVersion)

  addon_version:SetText('v' .. addonVersion)
end)
net.Receive("botVersion", function()
  local len = net.ReadUInt(32)
  local compressedBotVersion = net.ReadData(len)
  local botVersion = util.Decompress(compressedBotVersion)

  bot_version:SetText('v' .. botVersion)
end)
function get_discord_app_versions()
  net.Start("request_addonVersion")
  net.SendToServer()
  net.Start("request_botVersion")
  net.SendToServer()
end
get_discord_app_versions()

xgui.hookEvent( "onProcessModules", nil, discord_about_panel.processModules )
xgui.addSubModule( "About", discord_about_panel, nil, "discord" )
