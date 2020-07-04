print('[Discord] '..'Loading: '..'utils/http.lua')
function httpFetch(req, params, callback, tries)
  local defaultTries = 3
  httpAdress = GetConVar("discordbot_endpoint"):GetString()
  http.Fetch(httpAdress..'/'..req,
    function(res)
      --print(res)
      callback(util.JSONToTable(res))
    end,
    function(err)
      print("Request to bot failed. Is the bot running?")
      print("Err: "..err)
      if (!tries) then tries = defaultTries end
      if (tries != 0) then httpFetch(req, params, callback, tries-1) end
    end, {req=req, params=util.TableToJSON(params)}
  )
end