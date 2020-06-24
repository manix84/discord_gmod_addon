# TTT Discord Bot ![Icon](https://raw.githubusercontent.com/manix84/discord_gmod_bot/master/images/icon/icon_64x.png)

>Dead players tell no tales!

*... and that's basically what this bot does.*

[![price](https://img.shields.io/badge/price-free-brightgreen.svg)](LICENSE)
[![gmod-addon](https://img.shields.io/badge/gmod-addon-_.svg?colorB=1194EF)](https://wiki.garrysmod.com)
[![discord-bot](https://img.shields.io/badge/discord-bot-_.svg?colorB=8C9EFF)](https://discord.js.org)
[![license](https://img.shields.io/github/license/manix84/discord_gmod_bot.svg)](LICENSE)

This is a powerful [discord bot](https://discord.js.org) that mutes dead players in [TTT](http://ttt.badking.net) (Garry's Mod - Trouble in Terrorist Town)

## Getting Started
If you need a step-by-step tutorial, follow my [guide at steam](http://steamcommunity.com/sharedfiles/filedetails/?id=1351369388)

### Prerequisites
- You have to have already installed a Garry's Mod Server with the TTT Gamemode.
- You must have a [Nodejs](https://nodejs.org) installed locally on your GMod server, or on a publically accessable server (I used [Heroku.com](https://heroku.com), which is the easier of the two options)

### Usage

1. First and formost, you need to go setup the Discord Bot, so...
  - Go over to: [manix84/discord_gmod_bot](https://github.com/manix84/discord_gmod_bot.git)
  - Setup your node server
    > The following assumes you're using Heroku.com. If not, please skip.
    - 


- Start the bot by runing the node command with the `discord_gmod_bot` directory
- Connect your Steam Account with the bot by typing `!discord YourDiscordTag` in the ingame chat. E.g `!discord Manix84`.
- If you're in the **configured voice channel**, the game state is **in progress**, you're **connected with discord** and you die in TTT, the bot will mute you!

## Credits

- Marcel Transier - The original creator of [discord_gmod_bot](https://github.com/marceltransier/discord_gmod_bot.git), from which this is based.
- I used [discord.js](https://discord.js.org) in this project. Thanks for the easy opportunity writing a discord bot in javascript!
- Thanks for the great Garry's Mod gamemode [Trouble in Terrorist Town](http://ttt.badking.net) I made this bot for.

## Contributing

1. Fork it (<https://github.com/manix84/discord_gmod_bot/fork>)
2. Create your feature branch (`git checkout -b feature/fooBar`)
3. Commit your changes (`git commit -am 'Add some fooBar'`)
4. Push to the branch (`git push origin feature/fooBar`)
5. Create a new Pull Request

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
