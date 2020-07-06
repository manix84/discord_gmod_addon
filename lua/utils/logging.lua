CreateConVar("discord_debug", 0, 1, "Print debug messages to console.")

local enableDebugLogging = GetConVar("discord_debug"):GetBool()

function print_debug(...)
  if (enableDebugLogging) then
    print('[Discord]', ...)
  end
end