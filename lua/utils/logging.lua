print('[Discord] '..'Loading: '..'utils/logging.lua')

local enableDebugLogging = true;

function print_debug(msg)
  if (enableDebugLogging) then
    print('[Discord]' .. msg)
  end
end