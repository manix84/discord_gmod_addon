include('utils.lua')

resource.AddFile("materials/icon128/mute.png")
if (CLIENT) then
  drawMute = false
  muteIcon = Material("materials/icon128/mute.png")

  net.Receive("drawMute", function()
    drawMute = net.ReadBool()
  end)

  hook.Add( "HUDPaint", "discord_bot_commands_HUDPaint", function()
    if (!drawMute) then return end
    surface.SetDrawColor(176, 40, 40, 255)
    surface.SetMaterial(muteIcon)
    surface.DrawTexturedRect(192, 64, 128, 128)
  end )
  return
end

util.AddNetworkString("drawMute")
CreateConVar("discordbot_endpoint", "http://localhost:37405", 1, "Sets the node bot endpoint.")
CreateConVar("discordbot_name", "GMod Discord Bot", 1, "Sets the Plugin Prefix for helpermessages.") --The name which will be displayed in front of any Message
CreateConVar("discordbot_server_link", "https://discord.gg/", 1, "Sets the Discord server your bot is present on (eg: https://discord.gg/aBc123).")
CreateConVar("discordbot_mute_round", 1, 1, "Mute the player until the end of the round.", 0, 1)
CreateConVar("discordbot_mute_duration", 1, 1, "Sets how long, in seconds, you are muted for after death. No effect if mute_round is on. ", 1, 60)
CreateConVar("discordbot_auto_connect", 0, 1, "Attempt to automatically match player name to discord name. This happens silently when the player connects. If it fails, it will prompt the user with the '!discord NAME' message.", 0, 1)

muted = {}

connectionIDs = getConnectionIDs()
backupConnectionIDs(connectionIDs)


function sendClientIconInfo(ply, mute)
  net.Start("drawMute")
  net.WriteBool(mute)
  net.Send(ply)
end

function isMuted(ply)
  return muted[ply]
end

function mute(ply, duration)
  if (connectionIDs[ply:SteamID()]) then
    if (!isMuted(ply)) then
      httpFetch("mute", {mute=true, id=connectionIDs[ply:SteamID()]}, function(res)
        if (res) then
          --PrintTable(res)
          if (res.success) then
            if (duration) then
              print_message("You're muted in discord for "..duration.." seconds.", ply)
              timer.Simple(duration, function() unmute(ply) end)
            else
              print_message("You're muted in discord until the round ends.", ply)
            end
            sendClientIconInfo(ply, true)
            muted[ply] = true
          end
          if (res.error) then
            print_message("Error: "..res.err)
          end
        end
      end)
    end
  end
end

function unmute(ply)
  if (ply) then
    if (connectionIDs[ply:SteamID()]) then
      if (isMuted(ply)) then
        httpFetch("mute", {mute=false, id=connectionIDs[ply:SteamID()]}, function(res)
          if (res.success) then
            if (ply) then
              print_message("You're no longer muted in discord!", ply)
            end
            sendClientIconInfo(ply, false)
            muted[ply] = false
          end
          if (res.error) then
            print("Error: "..res.err)
          end
        end)
      end
    end
  else
    for ply,val in pairs(muted) do
      if val then unmute(ply) end
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

function joinMessage(ply)
  print_message("Join the discord server - "..GetConVar("discordbot_server_link"):GetString(), ply)
  print_message("Then link up by saying '!discord DISCORD_NAME' in the chat. E.g. '!discord Manix84'", ply)
end

hook.Add("PlayerSay", "discord_bot_commands_PlayerSay", function(ply, msg)
  if (string.sub(msg,1,9) != '!discord ') then
    if (string.sub(msg,1,8) == '!discord') then
      joinMessage(ply)
    end
    return ""
  end
  
  tag = string.sub(msg,10)
  tag_utf8 = ""

  for p, c in utf8.codes(tag) do
    tag_utf8 = string.Trim(tag_utf8.." "..c)
  end
  httpFetch("connect", {tag=tag_utf8}, function(res)
    if (res.answer == 0) then print_message("No guilde member with a discord tag like '"..tag.."' found.", ply) end
    if (res.answer == 1) then print_message("Found more than one user with a discord tag like '"..tag.."'. Try your full tag, EG: Manix84#1234", ply) end
    if (res.tag and res.id) then
      print_message("Discord tag '"..res.tag.."' successfully boundet to SteamID '"..ply:SteamID().."'", ply) --lie! actually the discord id is bound! ;)
      connectionIDs[ply:SteamID()] = res.id
      writeConnectionIDs(connectionIDs)
    end
  end)
  return ""
end)

hook.Add("PlayerInitialSpawn", "discord_bot_commands_PlayerInitialSpawn", function(ply)
  if (connectionIDs[ply:SteamID()]) then
    print_message("You are connected with discord.", ply)
  else
    if (GetConVar("discordbot_auto_connect"):GetBool()) then

      tag = ply:Name()
      tag_utf8 = ""

      for p, c in utf8.codes(tag) do
        tag_utf8 = string.Trim(tag_utf8.." "..c)
      end
      httpFetch("connect", {tag=tag_utf8}, function(res)
     	 -- print_message("Attempting to match your name, "..tag)
        if (res.tag and res.id) then
          print_message("Discord tag '"..res.tag.."' successfully bound to SteamID '"..ply:SteamID().."'", ply)
          addConnectionID(ply, res.id)
        else
          joinMessage(ply)
        end
      end)
    else
      joinMessage(ply)
    end
  end
end)

hook.Add("ConnectPlayer", "discord_bot_commands_ConnectPlayer", function(ply, discordID)
  addConnectionID(ply, discordID)
end)

hook.Add("ConnectPlayer_Name", "discord_bot_commands_ConnectPlayer_ByName", function(ply, discordName)

end)

hook.Add("DisconnectPlayer", "discord_bot_commands_DisconnectPlayer", function(ply)
  removeConnectionID(ply)
end)

hook.Add("MutePlayer", "discord_bot_commands_MutePlayer", function(ply, duration)
  if (duration > 0) then
    mute(ply, duration)
  else
    mute(ply)
  end
end)
hook.Add("UnmutePlayer", "discord_bot_commands_UnmutePlayer", function(ply)
  unmute(ply)
end)

hook.Add("PlayerSpawn", "discord_bot_commands_PlayerSpawn", function(ply)
  unmute(ply)
end)
hook.Add("PlayerDisconnected", "discord_bot_commands_PlayerDisconnected", function(ply)
  unmute(ply)
end)
hook.Add("ShutDown", "discord_bot_commands_ShutDown", function()
  unmute()
end)
hook.Add("TTTEndRound", "discord_bot_commands_TTTEndRound", function()
  timer.Simple(0.1, function() unmute() end)
end)
hook.Add("TTTBeginRound", "discord_bot_commands_TTTBeginRound", function()--in case of round-restart via command
  unmute()
end)
hook.Add("OnEndRound", "discord_bot_commands_OnEndRound", function()
  timer.Simple(0.1, function() unmute() end)
end)
hook.Add("OnStartRound", "discord_bot_commands_OnStartRound", function()
  unmute()
end)
hook.Add("PostPlayerDeath", "discord_bot_commands_PostPlayerDeath", function(ply)
  if (commonRoundState() == 1) then
    if (GetConVar("discordbot_mute_round"):GetBool()) then
      mute(ply)
    else
      local duration = GetConVar("discordbot_mute_duration"):GetInt()
      mute(ply, duration)
    end
  end
end)
