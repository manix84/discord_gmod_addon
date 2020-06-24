local connectionsTable = {}

local FILEPATH = "discord_connection_cache"

function print_message(message, ply)
  if (!ply) then
    PrintMessage(HUD_PRINTTALK, "["..GetConVar("discordbot_name"):GetString().."] "..message)
  else
    ply:PrintMessage(HUD_PRINTTALK, "["..GetConVar("discordbot_name"):GetString().."] "..message)
  end
end

function backupConnectionIDs(connectionsTable)
  local Timestamp = os.time()
  local TimeString = os.date( "%Y%m%d%H" , Timestamp )
  local backupFileName = FILEPATH..'_BACKUP_'..TimeString
  file.Write( backupFileName..'.json', util.TableToJSON(connectionsTable))
  print("Discord Connection IDs Backed Up to: "..backupFileName..'.json')
end


function getConnectionIDs()
  local rawConnectionIDsFromCache = file.Read( FILEPATH..'.json', 'DATA' )
  print('Attempting to collect from ConnectionID cache from '..FILEPATH..'.json')
  if (rawConnectionIDsFromCache) then
    connectionsTable = util.JSONToTable(rawConnectionIDsFromCache)
    print('ConnectionID cache collected: '..rawConnectionIDsFromCache)
  else
    print('ConnectionID cache failure: ', rawConnectionIDsFromCache)
  end
  return connectionsTable
end

function writeConnectionIDs(connectionsTable)
  file.Write( FILEPATH..'.json', util.TableToJSON(connectionsTable) )

  local writtenConnectionsTable = file.Read( FILEPATH..'.json', 'DATA' )
  if (writtenConnectionsTable == util.TableToJSON(connectionsTable)) then
    print("Cache written.")
  else
    print("Cache write failed.")
  end
end

function addConnectionID(ply, discordID)
  connectionsTable[ply:SteamID()] = discordID
  writeConnectionIDs(connectionsTable)
end

function removeConnectionID(ply)
  connectionsTable[ply:SteamID()] = nil
  writeConnectionIDs(connectionsTable)
end