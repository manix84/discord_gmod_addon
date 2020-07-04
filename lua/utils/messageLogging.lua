local enableDebugLogging = false;

function print_debug_log(msg)
  if (enableDebugLogging) then
    print(msg)
  end
end

function print_message(message, ply)
  if (!ply) then
    PrintMessage(HUD_PRINTTALK, "["..GetConVar("discordbot_name"):GetString().."] "..message)
  else
    ply:PrintMessage(HUD_PRINTTALK, "["..GetConVar("discordbot_name"):GetString().."] "..message)
  end
end