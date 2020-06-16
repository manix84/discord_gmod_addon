local CATEGORY_NAME = "Discord"

function ulx.dmute(calling_ply, target_ply, duration, should_mute)
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

local dmute = ulx.command(CATEGORY_NAME, "ulx dmute", ulx.dmute, "!dmute", true)
dmute:addParam{ type=ULib.cmds.PlayerArg, hint="Mute player until round start" }
dmute:addParam{ type=ULib.cmds.NumArg, min=0, max=60, default=1, hint="duration, 0 is round end", ULib.cmds.optional, ULib.cmds.round }
dmute:setOpposite( "ulx dunmute", {_, _, _, true}, "!dunmute", true )

dmute:defaultAccess(ULib.ACCESS_ADMIN)
dmute:help("Mutes the player in Discord")