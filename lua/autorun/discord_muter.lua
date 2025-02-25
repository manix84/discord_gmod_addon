AddCSLuaFile();
if Server then
  include("discord/utils/logging.lua");
  include("discord/utils/messaging.lua");
  include("discord/utils/discord_connection.lua");
  include("discord/utils/http.lua");
end
resource.AddFile("materials/icon256/mute.png");

if (CLIENT) then
  shouldDrawMute = false;
  muteIconAsset = Material("materials/icon256/mute.png", "smooth mips");

  net.Receive("drawMute", function()
    shouldDrawMute = net.ReadBool();
  end);

  hook.Add("HUDPaint", "discord_HUDPaint", function()
    if (not shouldDrawMute) then return; end
    surface.SetDrawColor(176, 40, 40, 255);
    surface.SetMaterial(muteIconAsset);
    surface.DrawTexturedRect(32, 32, 256, 256);
  end);

  return;
end

util.AddNetworkString("drawMute");
util.AddNetworkString("connectDiscordID");
util.AddNetworkString("discordPlayerTable");
util.AddNetworkString("request_discordPlayerTable");
util.AddNetworkString("discordTestConnection");
util.AddNetworkString("request_discordTestConnection");
util.AddNetworkString("addonVersion");
util.AddNetworkString("request_addonVersion");
util.AddNetworkString("botVersion");
util.AddNetworkString("request_botVersion");
CreateConVar("discord_endpoint", "http://localhost:37405", 1, "Sets the node bot endpoint.");
CreateConVar("discord_api_key", "", 1, "Sets the node bot api-key.");
CreateConVar("discord_name", "Discord", 1, "Sets the Plugin Prefix for helpermessages."); --The name which will be displayed in front of any Message
CreateConVar("discord_server_link", "https://discord.gg/", 1, "Sets the Discord server your bot is present on (eg: https://discord.gg/aBc123).");
CreateConVar("discord_mute_round", 1, 1, "Mute the player until the end of the round.", 0, 1);
CreateConVar("discord_mute_duration", 5, 1, "Sets how long, in seconds, you are muted for after death. No effect if mute_round is on. ", 1, 60);
CreateConVar("discord_auto_connect", 0, 1, "Attempt to automatically match player name to discord name. This happens silently when the player connects. If it fails, it will prompt the user with the \"!discord NAME\" message.", 0, 1);
local mutedPlayerTable = {};
local steamIDToDiscordIDConnectionTable = getConnectionIDs();

function drawMuteIcon(target_ply, drawMute)
  net.Start("drawMute");
  net.WriteBool(drawMute);
  net.Send(target_ply);
end

function isMuted(target_ply)
  return mutedPlayerTable[target_ply];
end

function unmutePlayer(target_ply)
  if (target_ply and steamIDToDiscordIDConnectionTable[target_ply:SteamID()] and isMuted(target_ply)) then
    httpFetch("mute", {
      mute = false,
      id = steamIDToDiscordIDConnectionTable[target_ply:SteamID()]
    }, function(res)
      if (res.success) then
        if (target_ply) then
          playerMessage("UNMUTED", target_ply);
        end

        drawMuteIcon(target_ply, false);
        mutedPlayerTable[target_ply] = false;
      end

      if (res.errorMsg) then
        announceMessage("ERROR_MESSAGE", res.errorMsg);
      end
    end);
  else
    for ply, val in pairs(mutedPlayerTable) do
      if val then
        unmutePlayer(ply);
      end
    end
  end
end

-- UnMute Player Alias (for compatability)
function unmute(target_ply)
  unmutePlayer(target_ply);
end

function mutePlayer(target_ply, duration)
  if (target_ply and steamIDToDiscordIDConnectionTable[target_ply:SteamID()] and not isMuted(target_ply)) then
    httpFetch("mute", {
      mute = true,
      id = steamIDToDiscordIDConnectionTable[target_ply:SteamID()]
    }, function(res)
      if (res and res.success) then
        if (duration) then
          playerMessage("MUTED_FOR_DURATION", target_ply, duration);

          timer.Simple(duration, function()
            unmutePlayer(target_ply);
          end);
        else
          playerMessage("MUTED_FOR_ROUND", target_ply);
        end

        drawMuteIcon(target_ply, true);
        mutedPlayerTable[target_ply] = true;
      elseif (res and res.errorMsg) then
        announceMessage("ERROR_MESSAGE", res.errorMsg);
      end
    end);
  end
end

-- Mute Player Alias (for compatability)
function mute(target_ply)
  mutePlayer(target_ply);
end

function commonRoundState()
  if (gmod.GetGamemode().Name == "Trouble in Terrorist Town" or gmod.GetGamemode().Name == "TTT2 (Advanced Update)") then return (GetRoundState() == 3) and 1 or 0; end -- Round state 3 => Game is running
  if (gmod.GetGamemode().Name == "Murder") then return (gmod.GetGamemode():GetRound() == 1) and 1 or 0; end -- Round state 1 => Game is running
  -- Round state could not be determined

  return -1;
end

function joinMessage(target_ply)
  playerMessage("JOIN_DISCORD_PROMPT", target_ply, GetConVar("discord_server_link"):GetString());
  playerMessage("CONNECTION_INSTRUCTIONS", target_ply);
end

function botSync(callback)
  timer.Create("botSyncTimeout", 2.0, 0, function()
    local responseTable = {};
    responseTable["success"] = false;
    responseTable["error"] = "host connection failure";
    responseTable["errorMsg"] = "host connection failure";
    responseTable["errorId"] = "HOST_MISSCONFIGURED";
    callback(responseTable);
    timer.Remove("botSyncTimeout");
  end);

  timer.Start("botSyncTimeout");

  httpFetch("sync", {}, function(res)
    timer.Remove("botSyncTimeout");
    callback(res);
  end);
end

net.Receive("connectDiscordID", function(len, calling_ply)
  if not calling_ply:IsSuperAdmin() then return; end
  local target_ply = net.ReadEntity();
  local discordID = net.ReadString();
  addConnectionID(target_ply, discordID);
end);

net.Receive("request_discordPlayerTable", function(len, calling_ply)
  if not calling_ply:IsSuperAdmin() then return; end
  local connectionsJSON = util.TableToJSON(steamIDToDiscordIDConnectionTable);
  local compressedConnections = util.Compress(connectionsJSON);
  net.Start("discordPlayerTable");
  net.WriteUInt(#compressedConnections, 32);
  net.WriteData(compressedConnections, #compressedConnections);
  net.Send(calling_ply);
end);

net.Receive("request_discordTestConnection", function(len, calling_ply)
  if not calling_ply:IsSuperAdmin() then return; end

  botSync(function(res)
    local connectionsJSON = util.TableToJSON(res);
    local compressedConnections = util.Compress(connectionsJSON);
    net.Start("discordTestConnection");
    net.WriteUInt(#compressedConnections, 32);
    net.WriteData(compressedConnections, #compressedConnections);
    net.Send(calling_ply);
  end);
end);

net.Receive("request_botVersion", function(len, calling_ply)
  if not calling_ply:IsAdmin() then return; end

  botSync(function(res)
    local botVersion = res["version"];
    local compressedBotVersion = util.Compress(botVersion);
    net.Start("botVersion");
    net.WriteUInt(#compressedBotVersion, 32);
    net.WriteData(compressedBotVersion, #compressedBotVersion);
    net.Send(calling_ply);
  end);
end);

net.Receive("request_addonVersion", function(len, calling_ply)
  if not calling_ply:IsAdmin() then return; end
  local addonVersion = "1.7.0";
  local compressedAddonVersion = util.Compress(addonVersion);
  net.Start("addonVersion");
  net.WriteUInt(#compressedAddonVersion, 32);
  net.WriteData(compressedAddonVersion, #compressedAddonVersion);
  net.Send(calling_ply);
end);

hook.Add("PlayerSay", "discord_PlayerSay", function(target_ply, msg)
  if (string.sub(msg, 1, 9) ~= "!discord ") then return; end
  tag = string.sub(msg, 10);
  tag_utf8 = "";

  for p, c in utf8.codes(tag) do
    tag_utf8 = string.Trim(tag_utf8 .. " " .. c);
  end

  httpFetch("connect", {
    tag = tag_utf8
  }, function(res)
    if (res.answer == 0) then
      playerMessage("NAME_NOT_FOUND", target_ply, tag);
    end

    if (res.answer == 1) then
      playerMessage("MULTIPLE_NAMES_FOUND", target_ply, tag);
    end

    if (res.tag and res.id) then
      playerMessage("CONNECTION_SUCCESSFUL", target_ply, target_ply:Nick(), target_ply:SteamID(), res.tag);
      steamIDToDiscordIDConnectionTable[target_ply:SteamID()] = res.id;
      writeConnectionIDs(steamIDToDiscordIDConnectionTable);
    end
  end);

  return "";
end);

hook.Add("PlayerInitialSpawn", "discord_PlayerInitialSpawn", function(target_ply)
  if (steamIDToDiscordIDConnectionTable[target_ply:SteamID()]) then
    playerMessage("WELCOME_CONNECTED", target_ply);
  else
    if (GetConVar("discord_auto_connect"):GetBool()) then
      tag = target_ply:Name();
      tag_utf8 = "";

      for p, c in utf8.codes(tag) do
        tag_utf8 = string.Trim(tag_utf8 .. " " .. c);
      end

      httpFetch("connect", {
        tag = tag_utf8
      }, function(res)
        -- playerMessage("AUTOMATIC_MATCH", target_ply, tag)
        if (res.tag and res.id) then
          playerMessage("Discord tag \"" .. res.tag .. "\" successfully bound to SteamID \"" .. target_ply:SteamID() .. "\"", target_ply);
          addConnectionID(target_ply, res.id);
        else
          joinMessage(target_ply);
        end
      end);
    else
      joinMessage(target_ply);
    end
  end
end);

hook.Add("ConnectPlayer", "discord_ConnectPlayer", function(target_ply, discordID)
  addConnectionID(target_ply, discordID);
end);

hook.Add("DisconnectPlayer", "discord_DisconnectPlayer", function(target_ply)
  removeConnectionID(target_ply);
end);

hook.Add("MutePlayer", "discord_MutePlayer", function(target_ply, duration)
  if (duration > 0) then
    mutePlayer(target_ply, duration);
  else
    mutePlayer(target_ply);
  end
end);

hook.Add("UnmutePlayer", "discord_UnmutePlayer", function(target_ply)
  unmutePlayer(target_ply);
end);

hook.Add("PlayerSpawn", "discord_PlayerSpawn", function(target_ply)
  unmutePlayer(target_ply);
end);

hook.Add("PlayerDisconnected", "discord_PlayerDisconnected", function(target_ply)
  unmutePlayer(target_ply);
end);

hook.Add("ShutDown", "discord_ShutDown", function()
  unmutePlayer();
end);

hook.Add("OnEndRound", "discord_OnEndRound", function()
  timer.Simple(0.1, function()
    unmutePlayer();
  end);
end);

hook.Add("OnStartRound", "discord_OnStartRound", function()
  unmutePlayer();
end);

hook.Add("PostPlayerDeath", "discord_PostPlayerDeath", function(target_ply)
  if (commonRoundState() == 1) then
    if (GetConVar("discord_mute_round"):GetBool()) then
      mutePlayer(target_ply);
    else
      local duration = GetConVar("discord_mute_duration"):GetInt();
      mutePlayer(target_ply, duration);
    end
  end
end);

-- TTT Specific
hook.Add("TTTEndRound", "discord_TTTEndRound", function()
  timer.Simple(0.1, function()
    unmutePlayer();
  end);
end);

hook.Add("TTTBeginRound", "discord_TTTBeginRound", function()
  unmutePlayer();
end);
