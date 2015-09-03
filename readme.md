# dctvbot
A simple IRC bot for chatrealm, built using [Cinch](https://github.com/cinchrb/cinch)  

### Status Commands
**_Users with voice or higher can specify the `-v` option to have the reply shown in main chat._**  

`!now [-v]` - Display channels that are currently live via user notice.  
`!next [-v]` - Display next scheduled show and estimated time until it starts.  
`!schedule [-v]` - Display scheduled shows for the next 48 hours via user notice.  

### Second Screen Commands
**_Restricted to users with voice or higher._**  

`!secs [on|off|clear|<url>]` - Executes Second Screen command or sets to `<url>`. Automatically generates a pastebin of links sent to the second screen between `on` and `off` commands.  

### Control Commands
**_Restricted to users with voice or higher._**  

`!turn [cleverbot|dctv|all] [on|off]` - Turns the specified set of commands on or off  
`!setjoin [on|off|status|<message>]` - Turns on/off, displays status of, or sets a user notice when they join the channel  

## Live Announcements
dctvbot will announce channels when they go live or are reserved for upcoming events on [diamondclub.tv](https://diamondclub.tv). If that channel is an official one, dctvbot will also update the topic with the announcement.  

Sample upcoming announcement:  
![Live Announcement](https://dl.dropboxusercontent.com/u/18589646/dctvbot_announce_soon.png)  
Sample live announcement:  
![Live Announcement](https://dl.dropboxusercontent.com/u/18589646/dctvbot_announce_live.png)  

## Cleverbot Integration
Mentioning dctvbot in chat will trigger a response from [cleverbot.com](https://cleverbot.com) by sending your message to their api.  

**Twitter Integration**  
The cleverbot integration extends to twitter for replies to mentions of [@dctvbot](https://twitter.com/dctvbot)  
