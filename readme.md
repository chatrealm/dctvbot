[![Chatrealm IRC][chatrealm-badge]][chatrealm-link]
[![Diamondclub.tv][dctv-badge]][dctv-link]

# dctvbot
Simple IRC bot for chatrealm and diamondclub.tv
* Announces channels when they go live
* Updates topic for live programs on channel 1
* Relays calendar and status info via commands

## Commands
`!now [v]` - Display channels that are currently live.  
`!next` - Display next scheduled show and estimated time until it starts.  
`!schedule [v]` - Display scheduled shows for the next 24 hours.  
_The `v` option will show the reply main chat, requires voice status (or better)._  
  
`!secs [on|off|clear|<url>]` - Sends `on`, `off`, `clear`, or `<url>` to [Second Screen](http://diamondclub.tv/secondscreen), requires voice status (or better).

## Docker instructions
```bash
# Clone the repository
git clone https://github.com/chatrealm/dctvbot.git
cd dctvbot

# Rename sample config file
cp src/config/config.sample.js src/config/config.js

# Edit src/config/config.js with desired settings

# Build and run docker image
docker build -t dctvbot .
docker run -d --name dctvbot dctvbot
```

[dctv-link]: https://diamondclub.tv
[dctv-badge]: https://img.shields.io/badge/diamondclub-tv-blue.svg?style=flat-square

[chatrealm-link]: https://irc.chatrealm.net
[chatrealm-badge]: https://img.shields.io/badge/chatrealm-irc-orange.svg?style=flat-square
