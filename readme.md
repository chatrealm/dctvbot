[![Chatrealm IRC][chatrealm-badge]][chatrealm-link]
[![Diamondclub.tv][dctv-badge]][dctv-link]

# dctvbot
Simple IRC bot for chatrealm and diamondclub.tv

## Commands
`!now [v]` - Display channels that are currently live via user notice.  
`!next [v]` - Display next scheduled show and estimated time until it starts.  
`!schedule [v]` - Display scheduled shows for the next 48 hours via user notice.  
_The `v` option will show the reply main chat, requires voice status (or better)._  
  
`!secs [on|off|clear|<url>]` - Sends `on`, `off`, `clear`, or `<url>` to [Second Screen](http://diamondclub.tv/secondscreen), requires voice status (or better).

## Channel Announcements
Sample upcoming announcement:  
![Live Announcement](https://dl.dropboxusercontent.com/u/18589646/dctvbot_announce_soon.png)  
Sample live announcement:  
![Live Announcement](https://dl.dropboxusercontent.com/u/18589646/dctvbot_announce_live.png)  

## Docker instructions

```bash
# Clone the repository
git clone https://github.com/chatrealm/dctvbot.git
cd dctvbot

# Copy sample config file
cp config/config.sample.js config/config.js

# MAKE SURE TO EDIT config/config.js WITH DESIRED SETTINGS

# Install required node modules
npm install
# Build js files
npm run build

# Build docker image
docker build -t dctvbot .

# Run docker image
docker run -d --name dctvbot dctvbot
```

[dctv-link]: https://diamondclub.tv
[dctv-badge]: https://img.shields.io/badge/diamondclub-tv-blue.svg?style=flat-square

[chatrealm-link]: https://irc.chatrealm.net
[chatrealm-badge]: https://img.shields.io/badge/chatrealm-irc-orange.svg?style=flat-square
