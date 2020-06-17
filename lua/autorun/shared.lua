AddCSLuaFile()
resource.AddFile("materials/icon128/mute.png")
if (CLIENT) then
  drawMute = false
  muteIcon = Material("materials/icon128/mute.png")

  net.Receive("drawMute", function()
    drawMute = net.ReadBool()
  end)

  hook.Add( "HUDPaint", "gmod_discord_bot_HUDPaint", function()
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

FILEPATH = "gmod_discord_bot.dat"
TRIES = 3

muted = {}

ids = {}
ids_raw = file.Read( FILEPATH, "DATA" )
if (ids_raw) then
  ids = util.JSONToTable(ids_raw)
end

function saveIDs()
  file.Write( FILEPATH, util.TableToJSON(ids))
end

function addPlayerID(ply, id)
  ids[ply:SteamID()] = id
  saveIDs()
end

function removePlayerID(ply)
  ids[ply:SteamID()] = nil
  saveIDs()
end

function print_message(message, ply)
  if (!ply) then
    PrintMessage(HUD_PRINTTALK, "["..GetConVar("discordbot_name"):GetString().."] "..message)
  else
    ply:PrintMessage(HUD_PRINTTALK, "["..GetConVar("discordbot_name"):GetString().."] "..message)
  end
end

function httpFetch(req, params, cb, tries)
  httpAdress = GetConVar("discordbot_endpoint"):GetString()
  http.Fetch(httpAdress..'/'..req,
    function(res)
      --print(res)
      cb(util.JSONToTable(res))
    end,
    function(err)
      print_message("Request to bot failed. Is the bot running?")
      print_message("Err: "..err)
      if (!tries) then tries = TRIES end
      if (tries != 0) then httpFetch(req, params, cb, tries-1) end
    end, {req=req, params=util.TableToJSON(params)}
  )
end

function sendClientIconInfo(ply, mute)
  net.Start("drawMute")
  net.WriteBool(mute)
  net.Send(ply)
end

function isMuted(ply)
  return muted[ply]
end

function mute(ply, duration)
  if (ids[ply:SteamID()]) then
    if (!isMuted(ply)) then
      httpFetch("mute", {mute=true,id=ids[ply:SteamID()]}, function(res)
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
    if (ids[ply:SteamID()]) then
      if (isMuted(ply)) then
        httpFetch("mute", {mute=false,id=ids[ply:SteamID()]}, function(res)
          if (res.success) then
            if (ply) then
              print_message("You're no longer muted in discord!", ply)
            end
            sendClientIconInfo(ply,false)
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

hook.Add("PlayerSay", "gmod_discord_bot_PlayerSay", function(ply, msg)
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
      ids[ply:SteamID()] = res.id
      saveIDs()
    end
  end)
  return ""
end)

hook.Add("PlayerInitialSpawn", "gmod_discord_bot_PlayerInitialSpawn", function(ply)
  if (ids[ply:SteamID()]) then
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
          addPlayerID(ply, res.id)
        else
          joinMessage(ply)
        end
      end)
    else
      joinMessage(ply)
    end
  end
end)

hook.Add("ConnectPlayer_ID", "gmod_discord_bot_ConnectPlayer_ID", function(ply, discordID)
  addPlayerID(ply, discordID)
end)

hook.Add("ConnectPlayer_Name", "gmod_discord_bot_ConnectPlayer_Name", function(ply, discordName)

end)

hook.Add("DisconnectPlayer", "gmod_discord_bot_RemovePlayer", function(ply)
  removePlayerID(ply)
end)

hook.Add("MutePlayer", "gmod_discord_bot_MutePlayer", function(ply, duration)
  if (duration > 0) then
    mute(ply, duration)
  else
    mute(ply)
  end
end)
hook.Add("UnmutePlayer", "gmod_discord_bot_UnmutePlayer", function(ply)
  unmute(ply)
end)

hook.Add("PlayerSpawn", "gmod_discord_bot_PlayerSpawn", function(ply)
  unmute(ply)
end)
hook.Add("PlayerDisconnected", "gmod_discord_bot_PlayerDisconnected", function(ply)
  unmute(ply)
end)
hook.Add("ShutDown", "gmod_discord_bot_ShutDown", function()
  unmute()
end)
hook.Add("TTTEndRound", "gmod_discord_bot_TTTEndRound", function()
  timer.Simple(0.1, function() unmute() end)
end)
hook.Add("TTTBeginRound", "gmod_discord_bot_TTTBeginRound", function()--in case of round-restart via command
  unmute()
end)
hook.Add("OnEndRound", "gmod_discord_bot_OnEndRound", function()
  timer.Simple(0.1, function() unmute() end)
end)
hook.Add("OnStartRound", "gmod_discord_bot_OnStartRound", function()
  unmute()
end)
hook.Add("PostPlayerDeath", "gmod_discord_bot_PostPlayerDeath", function(ply)
  if (commonRoundState() == 1) then
    if (GetConVar("discordbot_mute_round"):GetBool()) then
      mute(ply)
    else
      mute(ply, GetConVar("discordbot_mute_duration"):GetInt())
    end
  end
end)
