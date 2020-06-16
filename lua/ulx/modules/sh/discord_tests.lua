ulx_tsay_color_table = { "black", "white", "red", "blue", "green", "orange", "purple", "pink", "gray", "yellow" }

local CATEGORY_NAME = "Discord TEST"

function ulx.tsaycolor( calling_ply, message, color )
  local pink = Color( 255, 0, 97 )
  local white = Color( 255, 255, 255 )
  local black = Color( 0, 0, 0 )
  local red = Color( 255, 0, 0 )
  local blue = Color( 0, 0, 255 )
  local green = Color( 0, 255, 0 )
  local orange = Color( 255, 127, 0 )
  local purple = Color( 51, 0, 102 )
  local gray = Color( 96, 96, 96 )
  local grey = Color( 96, 96, 96 )
  local maroon = Color( 128, 0, 0 )
  local yellow = Color( 255, 255, 0 )

  if color == "pink" then
    ULib.tsayColor( nil, false, pink, message )
  elseif color == "white" then
    ULib.tsayColor( nil, false, white, message )
  elseif color == "black" then
    ULib.tsayColor( nil, false, black, message )
  elseif color == "red" then
    ULib.tsayColor( nil, false, red, message )
  elseif color == "blue" then
    ULib.tsayColor( nil, false, blue, message )
  elseif color == "green" then
    ULib.tsayColor( nil, false, green, message )
  elseif color == "orange" then
    ULib.tsayColor( nil, false, orange, message )
  elseif color == "purple" then
    ULib.tsayColor( nil, false, purple, message )
  elseif color == "gray" then
    ULib.tsayColor( nil, false, gray, message )
  elseif color == "grey" then
    ULib.tsayColor( nil, false, grey, message )
  elseif color == "maroon" then
    ULib.tsayColor( nil, false, maroon, message )
  elseif color == "yellow" then
    ULib.tsayColor( nil, false, yellow, message )
  elseif color == "default" then
    ULib.tsay( nil, message )
  end

  if util.tobool( GetConVarNumber( "ulx_logChat" ) ) then
    ulx.logString( string.format( "(tsay from %s) %s", calling_ply:IsValid() and calling_ply:Nick() or "Console", message ) )
  end
end

local tsaycolor = ulx.command( CATEGORY_NAME, "ulx tsaycolor", ulx.tsaycolor, "!color", true, true )
tsaycolor:addParam{ type=ULib.cmds.StringArg, hint="message" }
tsaycolor:addParam{ type=ULib.cmds.StringArg, hint="color", completes=ulx_tsay_color_table, ULib.cmds.restrictToCompletes } -- only allows values in that table
tsaycolor:defaultAccess( ULib.ACCESS_ADMIN )
tsaycolor:help( "Send a message to everyone in the chat box with color." )


function ulx.test_setup(calling_ply, target_ply, duration, should_mute)
  if should_mute then
    for i=1, #target_plys do
      target_plys[ i ]:DiscordMute( duration )
    end
    ulx.fancyLogAdmin( calling_ply, "#A muted #T for #i seconds", target_plys, duration )
  else
    for i=1, #target_plys do
      target_plys[ i ]:DiscordUnmute()
    end
    ulx.fancyLogAdmin( calling_ply, "#A unmuted #T", target_plys )
  end
end

local test_setup = ulx.command(CATEGORY_NAME, "ulx test_setup", ulx.test_setup, "!test_setup", true)
test_setup:addParam{ type=ULib.cmds.PlayerArg, hint="Mute player until round start" }

test_setup:defaultAccess(ULib.ACCESS_ADMIN)
test_setup:help("Mutes the player in Discord until round start")


function ulx.test_death_cycle(calling_ply, target_ply, duration, should_mute)
  if should_mute then
    for i=1, #target_plys do
      target_plys[ i ]:DiscordMute( duration )
    end
    ulx.fancyLogAdmin( calling_ply, "#A muted #T for #i seconds", target_plys, duration )
  else
    for i=1, #target_plys do
      target_plys[ i ]:DiscordUnmute()
    end
    ulx.fancyLogAdmin( calling_ply, "#A unmuted #T", target_plys )
  end
end

local test_death_cycle = ulx.command(CATEGORY_NAME, "ulx test_death_cycle", ulx.test_death_cycle, "!test_death_cycle", true)
test_death_cycle:addParam{ type=ULib.cmds.PlayerArg, hint="Mute player until round start" }

test_death_cycle:defaultAccess(ULib.ACCESS_ADMIN)
test_death_cycle:help("Mutes the player in Discord until round start")