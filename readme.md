# dctvbot
A simple IRC bot for chatrealm, built using [Cinch](https://github.com/cinchrb/cinch)

## Commands
:lock: - Requires at least **voice** status  
:closed_lock_with_key: - Requires at least **operator** status  
<br>
`!now [-v]` - Display channels that are currently live via user notice.  
`!next [-v]` - Display next scheduled show and estimated time until it starts.  
`!schedule [-v]` - Display scheduled shows for the next 48 hours via user notice.  
:lock:**_The `-v` option will show the reply main chat._**  
<br>
`!help <plugin>` - Displays general help or `<plugin>` help, if specified  
<br>
`!google [mode] <term>` - Returns top hit on google when searching for `<term>`. Optional `[mode]` can be one of blog, book, image, local, news, patent, or video.  
`!wiki <term>` - Searches Wikipedia for `<term>`.  
`!wolfram <term>` - Attempts to answer your `<term>` using Wolfram Alpha.  
`!urban <term>` - Returns result of Urban Dictionary search for `<term>`.  
<br>
:lock:`!poll <title> | <option>, <option>` - Requests a straw poll using `<title>` and a minimum of 2 `<option>` separated by commas  
:lock:`!secs [on|off|clear|<url>]` - Executes Second Screen command or sets to `<url>`. Automatically generates a pastebin of links sent to the second screen between `on` and `off` commands.  
<br>
:closed_lock_with_key:`!setjoin [on|off|status|<message>]` - Turns on/off, displays status of, or sets message on channel join to `<message>`.  
:closed_lock_with_key:`!plugin [load|unload|reload] <PluginName> <file_name>` - Un/re/loads `<PluginName>`, optionally using `<file_name>`.  
:closed_lock_with_key:`!plugin set <PluginName> <option> <value>` - Sets `<option>` to `<value>` for `<PluginName>`.  
`:closed_lock_with_key:!kill <bot_nick>` - Tells bot to quit completely, you must specify correct `<bot_nick>`

---

**Live Announcements**  
dctvbot will announce channels when they go live or are reserved for upcoming events on [diamondclub.tv](https://diamondclub.tv). If that channel is an official one, dctvbot will also update the topic with the announcement.  
<br>
Sample upcoming announcement:  
![Live Announcement](https://dl.dropboxusercontent.com/u/18589646/dctvbot_announce_soon.png)  
Sample live announcement:  
![Live Announcement](https://dl.dropboxusercontent.com/u/18589646/dctvbot_announce_live.png)  
<br>
**Cleverbot Integration**  
Mentioning dctvbot in chat will trigger a response from [cleverbot.com](https://cleverbot.com) by sending your message to their api.  
<br>
**Twitter Integration**  
The cleverbot integration extends to twitter for replies to mentions of [@dctvbot](https://twitter.com/dctvbot)
