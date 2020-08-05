function httpFetch(req, params, callback, tries)
  local defaultTries = 3
  httpsAdress = GetConVar("discord_endpoint"):GetString()
  http.Fetch(httpsAdress..'/'..req,
    function(res)
      --print(res)
      callback(util.JSONToTable(res))
    end,
    function(err)
      print("Request to bot failed. Is the bot running?")
      print("Err: "..err)
      if (!tries) then tries = defaultTries end
      if (tries != 0) then httpFetch(req, params, callback, tries-1) end
    end, {
      ["req"] = req,
      ["authorization"] = "Basic " .. GetConVar("discord_api_key"):GetString(),
      ["params"] = util.TableToJSON(params)
    }
  )
end