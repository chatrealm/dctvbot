[![Chatrealm IRC][irc-chatrealm-badge]][irc-chatrealm-link]
# dctvbot
A simple IRC bot for chatrealm, built using [Cinch](https://github.com/cinchrb/cinch)

## Commands
###### DCTV Info
`!now [-v]` - Display channels that are currently live via user notice.  
`!next [-v]` - Display next scheduled show and estimated time until it starts.  
`!schedule [-v]` - Display scheduled shows for the next 48 hours via user notice.  
_The `-v` option will show the reply main chat._

###### Utility
`!t <suggestion>` - Suggest a title for [Showbot](http://showbot.tv)  
`!t reset` - Reset title suggestions on [Showbot](http://showbot.tv)  
`!secs [on|off|clear|<url>]` - Executes Second Screen command or sets to `<url>`. Automatically generates a pastebin of links sent to the second screen between `on` and `off` commands.  
~~`!poll <title> | <option>, <option>` - Requests a straw poll using `<title>` and a minimum of 2 `<option>` separated by commas~~ SOON&trade;  
~~`!setjoin [on|off|status|<message>]` - Turns on/off, displays status of, or sets message on channel join to `<message>`.~~ SOON&trade;  
`!topic <info>` - Replace first portion of topic with `<info>`  
`!topic reset` - Resets the entire topic to default  
`!topic default <topic>` - Sets a new default topic

###### Maintenence
`!plugin [load|unload|reload] <PluginName> <file_name>` - Un/re/loads `<PluginName>`, optionally using `<file_name>`.  
`!plugin set <PluginName> <option> <value>` - Sets `<option>` to `<value>` for `<PluginName>`.  
`!kill <bot_nick>` - Tells bot to quit completely, you must specify correct `<bot_nick>`  

## Announcements
dctvbot will announce channels when they go live or are reserved for upcoming events on [diamondclub.tv](https://diamondclub.tv). If that channel is an official one, dctvbot will also update the topic with the announcement.  

Sample upcoming announcement:  
![Live Announcement](https://dl.dropboxusercontent.com/u/18589646/dctvbot_announce_soon.png)  
Sample live announcement:  
![Live Announcement](https://dl.dropboxusercontent.com/u/18589646/dctvbot_announce_live.png)  

[irc-chatrealm-link]: http://irc.chatrealm.net
[irc-chatrealm-badge]: https://img.shields.io/badge/irc-chatrealm-blue.svg
