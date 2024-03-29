# Discord Muter for GMod (The GMod Addon)
![Icon](https://raw.githubusercontent.com/manix84/discord_gmod_addon/master/images/icon/icon_128x.png)

>Dead players tell no tales!

*... and that's basically what this bot does.*

[![price](https://img.shields.io/badge/price-free-brightgreen.svg)](LICENSE)
[![gmod-addon](https://img.shields.io/badge/gmod-addon-_.svg?colorB=1194EF)](https://wiki.garrysmod.com)
[![discord-bot](https://img.shields.io/badge/discord-bot-_.svg?colorB=8C9EFF)](https://discord.js.org)
[![license](https://img.shields.io/github/license/manix84/discord_gmod_addon.svg)](LICENSE)

This mod, in conjunction with it's [Node Bot](https://github.com/manix84/discord_gmod_bot), mutes dead players for X seconds, or unil the end of the round in (Garry's Mod).

## Features
- Remote Node Bot (the node bot and the addon don't need to be on the same server, but they can be if you want).
- Secure & Authenticated connection, so no-one should be highjacking your bot communication.
- Discord Server link. When someone connects, they get told to join your server, if they're not already connected.
- Mute a Player for the entire round, or simply for a few seconds.
- Automatically connect players when they join your server. If a new player joins, they're on the Discord server already, and use the same name, they'll get connected without even prompting them.
- Language support (currently for player messages):
    - English (english, Default)
    - German (deutsche)
    - Turkish (turkce)
    - French (français)
    - Spanish (español)
- [ULX](https://steamcommunity.com/sharedfiles/filedetails/?id=557962280) Support:
    - Added Mute/Unmute in commands menu - Obviously, you can mute/unmute a player from the ULX menu
    - Added Discord Settings
        - "Settings" - You can change any of the Console Variables on a per Map basis.
        - "Player Connections" - You can add a Steam/Discord ID connection from the ULX menu.
- Node Bot KeepAlive. Some bot hosts kill the bot if they don't get connections after a while. This option will keep the bot running, between sessions.

## Getting Started
If you need a step-by-step tutorial, follow my [guide at steam](http://steamcommunity.com/sharedfiles/filedetails/?id=1351369388)

### Prerequisites
- You have to have already installed a [Garry's Mod](https://store.steampowered.com/app/4000/Garrys_Mod/) Server with the TTT Gamemode.
- You must have a [NodeJS](https://nodejs.org) installed locally on your GMod server, or on a publically accessable server (I used [Heroku.com](https://heroku.com), which is the easier of the two options)

### Installation
1. First and formost, you need to go setup the Discord Bot, so...
    - Go over to: [manix84/discord_gmod_bot](https://github.com/manix84/discord_gmod_bot.git)
    - Setup your node server
        > The following assumes you're using Heroku.com. If not, please skip.
        - Create a free account on [Heroku.com](https://heroku.com).
        - Create a pipeline, which deploys the [Discord Gmod Bot](https://github.com/manix84/discord_gmod_bot.git)
        - Set the Environment Variables:
            - `API_KEY`: (Optional, but super recommended) This MUST match the GMod server. It can be anything.
            - `DISCORD_GUILD`: A copy of the Server/Guild ID.
            - `DISCORD_CHANNEL`: A copy of the Voice Channel ID.
                - !If you're stuggling to get the Discord Guild/Channel ID, Discord have a [guide](https://support.discord.com/hc/en-us/articles/206346498-Where-can-I-find-my-User-Server-Message-ID-) to getting the ID's.
            - `DISCORD_TOKEN`: This allows the node bot to talk to the Discord Bot (You will get this in Step 3 below)
                - To get the `DISCORD_TOKEN`, you'll need to create a [Discord Bot](https://github.com/reactiflux/discord-irc/wiki/Creating-a-discord-bot-&-getting-a-token). You'll need to follow these instructions to invite the bot, into your server.
                - Make sure you grant the bot the permissions to Mute Members.
    - Make sure the Node Bot server is running. Heroku will run is as a web instance.
2. Install this Mod (I recommend using the [Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=2155238885))
    - If you don't want to use steam workshop, go over to: [manix84/discord_gmod_addon](https://github.com/manix84/discord_gmod_addon.git) and just extract the project into `/garrysmod/addons/discord'.
3. Make sure you've got the `server convars` in `/garrysmod/cfg/server.cfg`
    - `discord_endpoint`: The Node Bot remote endpoint (EG: https://my-awesome-discord-bot.herokuapp.com:443)
    - `discord_api_key`: This MUST match any value you set for the Node Bot. 
    - `discord_server_link`: This is the share link that is advertised on your gmod server.
    - `discord_mute_round`: Do you want to mute the end of the round after death? (1=Yes, 0=No)
    - `discord_mute_duration`: How long do you want the player to be muted after death, in seconds. Does nothing if `discord_mute_round` is set to `1`.
    - `discord_auto_connect`: If enabled, when an unknown player connects, it will try to match the Steam Nickname, to the Discord Nickname.  (1=Enabled, 0=Disabled)
4. You're all setup, so now, connect your Steam and Discord accounts:
    - Connect your Steam Account with the bot by typing `!discord YourDiscordTag` in the ingame chat (E.G `!discord Manix84`).
        - If you're having trouble, try your full discord name (E.G: `!discord Manix84#8429`). This should only be necessary if there are two or more people with the same name.
    - So long as you're in correct `DISCORD_GUILD` and `DISCORD_CHANNEL`, the game state is **in progress**, you're **connected to discord** and you die in a supported GMod gamemode (TTT, TTT2 - Advanced Update, or Murder), the bot will mute you!

## Variables

|Variable|Optional/Default|Description|
|--------|----------------|-----------|
|`discord_endpoint`|"http://localhost:37405"|The location of your Discord Node Bot. If you are running them on the same machine, you shouldn't need to set this.|
|`discord_api_key`|(optional)|The authorisation key Discord Node Bot. This is essential if you're running the node bot on another machine. It must also match, exactly, the API key set for the Node Bot.|
|`discord_name`|"Discord"|The prefix displayed to your players when the add-on sends them a message (EG: [Discord] You've been muted until the end of the round.)|
|`discord_server_link`|"https://discord.gg/"|The discord invite shown to players when they connect for the first time. (EG: [Discord] Join the discord server - https://discord.gg/yg6KJ8c/)|
|`discord_mute_round`|1|Should a players be muted until the round ends? (1=Yes, 0=No)|
|`discord_mute_duration`|5|How many seconds should a player be muted after death? (has no effect if discord_mute_round is enabled)|
|`discord_auto_connect`|0|Should the add-on try to match the Steam Nickname to the Discord Nickname of a player? (1=Enabled, 0=Disabled)|
|`discord_language`|"english"|Let's you specify the language the player sees. (Available Languages[github.com])|
|`discord_debug`|0|Shows all the debug messages used to help build and maintain the add-on. (1=Enabled, 0=Disabled)|

## Credits
- Marcel Transier - The original creator of [ttt_discord_bot](https://github.com/marceltransier/ttt_discord_bot.git), from which this is based.
- I used [discord.js](https://discord.js.org) in this project. Thanks for the easy opportunity writing a discord bot in javascript!
- Thanks for the great Garry's Mod gamemode [Trouble in Terrorist Town](http://ttt.badking.net) I made this bot for.

## Contributing
1. Fork it (<https://github.com/manix84/discord_gmod_addon/fork>)
2. Create your feature branch (`git checkout -b feature/featureName`)
3. Commit your changes (`git commit -am 'Add some featureName'`)
4. Push to the branch (`git push origin feature/featureName`)
5. Create a new Pull Request

### Adding a language
1. Just add a file into `/lua/discord/locale/[language_name].lua`.
    - The translation tool will pick it up automatically.
    - If you miss a translation key, they user will see "TRANSLATION MISSING", so... try to avoid that.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

## Screenshots

### Muting in action
![Muting in action](https://i.imgur.com/a2eBESP.png)

### ULX Commands
![ULX Cmds](https://i.imgur.com/pWUKAO8.png)

### ULX Settings - Settings
![ULX Settings - Settings](https://i.imgur.com/dDrGiuA.png)

### ULX Settings - Player Connections
![ULX Settings - Player Connections](https://i.imgur.com/r1caKBV.png)
