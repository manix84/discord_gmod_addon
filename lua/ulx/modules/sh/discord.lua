local CATEGORY_NAME = "Discord"

function ulx.mute(calling_ply, target_plys, duration, should_unmute)
  if (should_unmute) then
    for i=1, #target_plys do
      hook.Run("UnmutePlayer", target_plys[ i ])
    end
    ulx.fancyLogAdmin( calling_ply, "#A unmuted #T", target_plys )
  else
    for i=1, #target_plys do
      hook.Run("MutePlayer", target_plys[ i ], duration)
    end
    ulx.fancyLogAdmin( calling_ply, "#A muted #T for #i seconds", target_plys, duration )
  end
end

local mute = ulx.command(CATEGORY_NAME, "ulx mute", ulx.mute, "!mute")
mute:addParam{ type=ULib.cmds.PlayersArg }
mute:addParam{ type=ULib.cmds.NumArg, min=0, max=60, default=0, hint="duration, 0 is round end", ULib.cmds.optional, ULib.cmds.round }
mute:addParam{ type=ULib.cmds.BoolArg, invisible=true }
mute:setOpposite( "ulx unmute", {_, _, _, true}, "!unmute" )

mute:defaultAccess(ULib.ACCESS_ADMIN)
mute:help("Mute and Unmute the player in Discord")