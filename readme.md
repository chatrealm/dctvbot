# dctvbot
A simple IRC bot for chatrealm, built using [Cinch](https://github.com/cinchrb/cinch)  

## Status Commands
**_The `-v` option will show the reply main chat. Requires at least Voice status._**  

`!now [-v]` - Display channels that are currently live via user notice.<br>`!next [-v]` - Display next scheduled show and estimated time until it starts.<br>`!schedule [-v]` - Display scheduled shows for the next 48 hours via user notice.  

## Utility Commands
**_Requires at least Voice status._**  

`!poll <title> | <option>, <option>` - Requests a straw poll using `<title>` and a minimum of 2 `<option>` separated by commas<br>`!secs [on|off|clear|<url>]` - Executes Second Screen command or sets to `<url>`. Automatically generates a pastebin of links sent to the second screen between `on` and `off` commands.  

## Management Commands
**_Requires at least Operator status._**  

`!setjoin [on|off|status|<message>]` - Turns on/off, displays status of, or sets message on channel join to `<message>`.<br>`!plugin [load|unload|reload] <PluginName> <file_name>` - Un/re/loads `<PluginName>`, optionally using `<file_name>`.<br>`!plugin set <PluginName> <option> <value>` - Sets `<option>` to `<value>` for `<PluginName>`. `!kill <bot_nick>` - Tells bot to quit completely, you must specify correct `<bot_nick>`  

## Live Announcements
dctvbot will announce channels when they go live or are reserved for upcoming events on [diamondclub.tv](https://diamondclub.tv). If that channel is an official one, dctvbot will also update the topic with the announcement.  

Sample upcoming announcement:<br>![Live Announcement](https://dl.dropboxusercontent.com/u/18589646/dctvbot_announce_soon.png)<br>Sample live announcement:<br>![Live Announcement](https://dl.dropboxusercontent.com/u/18589646/dctvbot_announce_live.png)  

## Cleverbot Integration
Mentioning dctvbot in chat will trigger a response from [cleverbot.com](https://cleverbot.com) by sending your message to their api.  

**Twitter Integration**<br>The cleverbot integration extends to twitter for replies to mentions of [@dctvbot](https://twitter.com/dctvbot)  
