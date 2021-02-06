include("./logging.lua")

local connectionsTable = {}

local FILEPATH = "discord_connection_cache"

function backupConnectionIDs(connectionsTable)
  local Timestamp = os.time()
  local TimeString = os.date("%Y%m%d" , Timestamp)
  local backupFileName = FILEPATH .. "_BACKUP_" .. TimeString
  file.Write( backupFileName .. ".json", util.TableToJSON(connectionsTable, true))
  print_debug("Discord Connection IDs Backed Up to: " .. backupFileName .. ".json")
end

function getConnectionIDs()
  local rawConnectionIDsFromCache = file.Read( FILEPATH .. ".json", "DATA" )
  print_debug("Attempting to collect from ConnectionID cache from  " .. FILEPATH .. ".json")
  if (rawConnectionIDsFromCache) then
    connectionsTable = util.JSONToTable(rawConnectionIDsFromCache)
    print_debug("ConnectionID cache collected: " .. rawConnectionIDsFromCache)
  else
    print_debug("ConnectionID cache failure: ", rawConnectionIDsFromCache)
  end
  return connectionsTable
end

function writeConnectionIDs(connectionsTable)
  file.Write( FILEPATH .. ".json", util.TableToJSON(connectionsTable, true) )

  local writtenConnectionsTable = file.Read( FILEPATH .. ".json", "DATA" )
  if (writtenConnectionsTable == util.TableToJSON(connectionsTable, true)) then
    print_debug("Cache written.")
  else
    print_debug("Cache write failed.")
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
