function httpFetch(req, params, callback, tries)
  local defaultTries = 3
  httpsAdress = GetConVar("discord_endpoint"):GetString()
  http.Fetch(httpsAdress..'/'..req,
    function(res)
      if (util.JSONToTable(res).errorMsg) then
        print("["..GetConVar("discord_name"):GetString().."][Error] " .. util.JSONToTable(res).errorMsg)
      end
      callback(util.JSONToTable(res))
    end,
    function(err)
      print("["..GetConVar("discord_name"):GetString().."] Request to bot failed to respond. Is the bot running? Or is the URL correct?")
      print("["..GetConVar("discord_name"):GetString().."][Error] " .. err)
      if (!tries) then tries = defaultTries end
      if (tries != 0) then httpFetch(req, params, callback, tries-1) end
    end, {
      ["req"] = req,
      ["authorization"] = "Basic " .. GetConVar("discord_api_key"):GetString(),
      ["params"] = util.TableToJSON(params)
    }
  )
end
