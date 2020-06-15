local CATEGORY_NAME = "Discord Bot"

function ulx.discord_mute(calling_ply, target_ply, duration, should_mute)
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

local discord_mute = ulx.command(CATEGORY_NAME, "ulx discord_mute", ulx.discord_mute, "!discord_mute", true)
discord_mute:addParam{ type=ULib.cmds.PlayerArg, hint="Mute player until round start" }
discord_mute:addParam{ type=ULib.cmds.NumArg, min=1, max=60, hint="duration", ULib.cmds.round }
discord_mute:setOpposite( "ulx discord_unmute", {_, _, _, true}, "!discord_unmute", true )

discord_mute:defaultAccess(ULib.ACCESS_ADMIN)
discord_mute:help("Mutes the player in Discord until round start")