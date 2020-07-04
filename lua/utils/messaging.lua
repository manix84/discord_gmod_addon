print('[Discord] Loading: utils/messaging.lua')

function playerMessage(message, ply)
  if (!ply) then
    PrintMessage(HUD_PRINTTALK, "["..GetConVar("discordbot_name"):GetString().."] "..message)
  else
    ply:PrintMessage(HUD_PRINTTALK, "["..GetConVar("discordbot_name"):GetString().."] "..message)
  end
end