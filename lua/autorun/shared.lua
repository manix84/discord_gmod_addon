AddCSLuaFile()

resource.AddFile("materials/icon256/mute.png")
if (CLIENT) then
  shouldDrawMute = false
  muteIconAsset = Material("materials/icon256/mute.png", "smooth mips")

  net.Receive("drawMute", function()
    shouldDrawMute = net.ReadBool()
  end)

  hook.Add( "HUDPaint", "discord_HUDPaint", function()
    if (!shouldDrawMute) then
      return
    end
    surface.SetDrawColor(176, 40, 40, 255)
    surface.SetMaterial(muteIconAsset)
    surface.DrawTexturedRect(32, 32, 256, 256)
  end )
  return
end

include('utils/messaging.lua')
include('utils/logging.lua')
include('utils/discord_connection.lua')
include('utils/http.lua')

util.AddNetworkString("drawMute")
util.AddNetworkString("connectDiscordID")
util.AddNetworkString("discordPlayerTable")
util.AddNetworkString("request_discordPlayerTable")

CreateConVar("discord_endpoint", "http://localhost:37405", 1, "Sets the node bot endpoint.")
CreateConVar("discord_api_key", "", 1, "Sets the node bot api-key.")
CreateConVar("discord_name", "Discord", 1, "Sets the Plugin Prefix for helpermessages.") --The name which will be displayed in front of any Message
CreateConVar("discord_server_link", "https://discord.gg/", 1, "Sets the Discord server your bot is present on (eg: https://discord.gg/aBc123).")
CreateConVar("discord_mute_round", 1, 1, "Mute the player until the end of the round.", 0, 1)
CreateConVar("discord_mute_duration", 5, 1, "Sets how long, in seconds, you are muted for after death. No effect if mute_round is on. ", 1, 60)
CreateConVar("discord_auto_connect", 0, 1, "Attempt to automatically match player name to discord name. This happens silently when the player connects. If it fails, it will prompt the user with the '!discord NAME' message.", 0, 1)

local mutedPlayerTable = {}
local steamIDToDiscordIDConnectionTable = getConnectionIDs()

function drawMuteIcon(target_ply, shouldDrawMute)
  net.Start("drawMute")
  net.WriteBool(shouldDrawMute)
  net.Send(target_ply)
end

function isMuted(target_ply)
  return mutedPlayerTable[target_ply]
end

function mutePlayer(target_ply, duration)
  if (steamIDToDiscordIDConnectionTable[target_ply:SteamID()]) then
    if (!isMuted(target_ply)) then
      httpFetch("mute", {mute=true, id=steamIDToDiscordIDConnectionTable[target_ply:SteamID()]}, function(res)
        if (res) then
          --PrintTable(res)
          if (res.success) then
            if (duration) then
              playerMessage("You're muted for " .. duration .. " seconds.", target_ply)
              timer.Simple(duration, function() unmutePlayer(target_ply) end)
            else
              playerMessage("You're muted until the round ends.", target_ply)
            end
            drawMuteIcon(target_ply, true)
            mutedPlayerTable[target_ply] = true
          end
          if (res.error) then
            playerMessage("Error: " .. res.err)
          end
        end
      end)
    end
  end
end

function unmutePlayer(target_ply)
  if (target_ply) then
    if (steamIDToDiscordIDConnectionTable[target_ply:SteamID()]) then
      if (isMuted(target_ply)) then
        httpFetch("mute", {mute=false, id=steamIDToDiscordIDConnectionTable[target_ply:SteamID()]}, function(res)
          if (res.success) then
            if (target_ply) then
              playerMessage("You're no longer muted.", target_ply)
            end
            drawMuteIcon(target_ply, false)
            mutedPlayerTable[target_ply] = false
          end
          if (res.error) then
            print("Error: " .. res.err)
          end
        end)
      end
    end
  else
    for target_ply,val in pairs(mutedPlayerTable) do
      if val then
        unmutePlayer(target_ply)
    end
  end
end
end

function commonRoundState()
  if (gmod.GetGamemode().Name == "Trouble in Terrorist Town" or
    gmod.GetGamemode().Name == "TTT2 (Advanced Update)") then
    -- Round state 3 => Game is running
    return ((GetRoundState() == 3) and 1 or 0)
  end

  if (gmod.GetGamemode().Name == "Murder") then
    -- Round state 1 => Game is running
    return ((gmod.GetGamemode():GetRound() == 1) and 1 or 0)
  end

  -- Round state could not be determined
  return -1
end

function joinMessage(target_ply)
  playerMessage("Join the discord server - " .. GetConVar("discord_server_link"):GetString(), target_ply)
  playerMessage("Then link up by saying '!discord DISCORD_NAME' in the chat. E.g. '!discord Manix84'", target_ply)
end

net.Receive("connectDiscordID", function( len, calling_ply )
  if !calling_ply:IsSuperAdmin() then
    return
  end

  local target_ply = net.ReadEntity()
  local discordID = net.ReadString()
  addConnectionID(target_ply, discordID)
end)

net.Receive("request_discordPlayerTable", function( len, calling_ply )
  if !calling_ply:IsSuperAdmin() then
    return
  end

  local connectionsJSON = util.TableToJSON(steamIDToDiscordIDConnectionTable)
  local compressedConnections = util.Compress(connectionsJSON)

  net.Start("discordPlayerTable")
  net.WriteUInt(#compressedConnections, 32)
  net.WriteData(compressedConnections, #compressedConnections)
  net.Broadcast()
end)

hook.Add("PlayerSay", "discord_PlayerSay", function(target_ply, msg)
  if (string.sub(msg,1,9) != '!discord ') then
    return
  end
  tag = string.sub(msg,10)
  tag_utf8 = ""

  for p, c in utf8.codes(tag) do
    tag_utf8 = string.Trim(tag_utf8 .. " " .. c)
  end
  httpFetch("connect", {tag=tag_utf8}, function(res)
    if (res.answer == 0) then
      playerMessage("No server member with a name like '" .. tag .. "' found.", target_ply)
    end
    if (res.answer == 1) then
      playerMessage("Found more than one user with a name like '" .. tag .. "'. Try your full tag, EG: Manix84#1234", target_ply)
    end
    if (res.tag and res.id) then
      playerMessage("Discord tag '" .. res.tag .. "' successfully boundet to SteamID '" .. target_ply:SteamID() .. "'", target_ply) --lie! actually the discord id is bound! ;)
      steamIDToDiscordIDConnectionTable[target_ply:SteamID()] = res.id
      writeConnectionIDs(steamIDToDiscordIDConnectionTable)
    end
  end)
  return ""
end)

hook.Add("PlayerInitialSpawn", "discord_PlayerInitialSpawn", function(target_ply)
  if (steamIDToDiscordIDConnectionTable[target_ply:SteamID()]) then
    playerMessage("You are connected with discord.", target_ply)
  else
    if (GetConVar("discord_auto_connect"):GetBool()) then
      tag = target_ply:Name()
      tag_utf8 = ""

      for p, c in utf8.codes(tag) do
        tag_utf8 = string.Trim(tag_utf8 .. " " .. c)
      end
      httpFetch("connect", {tag=tag_utf8}, function(res)
     	 -- playerMessage("Attempting to match your name, " .. tag)
        if (res.tag and res.id) then
          playerMessage("Discord tag '" .. res.tag .. "' successfully bound to SteamID '" .. target_ply:SteamID() .. "'", target_ply)
          addConnectionID(target_ply, res.id)
        else
          joinMessage(target_ply)
        end
      end)
    else
      joinMessage(target_ply)
    end
  end
end)

hook.Add("ConnectPlayer", "discord_ConnectPlayer", function(target_ply, discordID)
  addConnectionID(target_ply, discordID)
end)

hook.Add("DisconnectPlayer", "discord_DisconnectPlayer", function(target_ply)
  removeConnectionID(target_ply)
end)

hook.Add("MutePlayer", "discord_MutePlayer", function(target_ply, duration)
  if (duration > 0) then
    mutePlayer(target_ply, duration)
  else
    mutePlayer(target_ply)
  end
end)
hook.Add("UnmutePlayer", "discord_UnmutePlayer", function(target_ply)
  unmutePlayer(target_ply)
end)

hook.Add("PlayerSpawn", "discord_PlayerSpawn", function(target_ply)
  unmutePlayer(target_ply)
end)
hook.Add("PlayerDisconnected", "discord_PlayerDisconnected", function(target_ply)
  unmutePlayer(target_ply)
end)
hook.Add("ShutDown", "discord_ShutDown", function()
  unmutePlayer()
end)
hook.Add("OnEndRound", "discord_OnEndRound", function()
  timer.Simple(0.1, function()
    unmutePlayer()
  end)
end)
hook.Add("OnStartRound", "discord_OnStartRound", function()
  unmutePlayer()
end)
hook.Add("PostPlayerDeath", "discord_PostPlayerDeath", function(target_ply)
  if (commonRoundState() == 1) then
    if (GetConVar("discord_mute_round"):GetBool()) then
      mutePlayer(target_ply)
    else
      local duration = GetConVar("discord_mute_duration"):GetInt()
      mutePlayer(target_ply, duration)
    end
  end
end)

-- TTT Specific
hook.Add("TTTEndRound", "discord_TTTEndRound", function()
  timer.Simple(0.1, function()
    unmutePlayer()
  end)
end)
hook.Add("TTTBeginRound", "discord_TTTBeginRound", function()
  unmutePlayer()
end)
