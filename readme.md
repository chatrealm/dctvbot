[![Chatrealm IRC][chatrealm-badge]][chatrealm-link]
[![Diamondclub.tv][dctv-badge]][dctv-link]

# dctvbot
Simple IRC bot for chatrealm and diamondclub.tv

## Commands
`!now [v]` - Display channels that are currently live via user notice.  
`!next` - Display next scheduled show and estimated time until it starts.  
`!schedule [v]` - Display scheduled shows for the next 24 hours via user notice.  
_The `v` option will show the reply main chat, requires voice status (or better)._  
  
`!secs [on|off|clear|<url>]` - Sends `on`, `off`, `clear`, or `<url>` to [Second Screen](http://diamondclub.tv/secondscreen), requires voice status (or better).

## Channel Announcements
Sample upcoming announcement:  
![Next Announcement](https://dl.dropboxusercontent.com/u/18589646/CDN/dctvbot_announce_next.png)  
Sample live announcement:  
![Live Announcement](https://dl.dropboxusercontent.com/u/18589646/CDN/dctvbot_announce_live.png)  

## Docker instructions
1. Clone the repository
    ```bash
    git clone https://github.com/chatrealm/dctvbot.git
    cd dctvbot
    
    # Rename sample config file
    mv src/config/config.sample.js src/config/config.js
    ```
2. Edit `src/config/config.js` with desired settings
3. Install, build and run
    ```bash
    npm install
    npm run build

    # Build and run docker image
    docker build -t dctvbot .
    docker run -d --name dctvbot dctvbot
    ```

[dctv-link]: https://diamondclub.tv
[dctv-badge]: https://img.shields.io/badge/diamondclub-tv-blue.svg?style=flat-square

[chatrealm-link]: https://irc.chatrealm.net
[chatrealm-badge]: https://img.shields.io/badge/chatrealm-irc-orange.svg?style=flat-square
