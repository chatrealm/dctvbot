# dctvbot
[![Code Climate](https://codeclimate.com/github/tinnvec/dctvbot/badges/gpa.svg)](https://codeclimate.com/github/tinnvec/dctvbot)  
A simple IRC bot for chatrealm, built using [Cinch](https://github.com/cinchrb/cinch)  

## DCTV Status Commands
**_Users with voice or higher can specify the `-v` option to have the reply shown in main chat._**  

`!now [-v]` - Display channels that are currently live via user notice.  
`!next [-v]` - Display next scheduled show and estimated time until it starts.  
`!schedule [-v]` - Display scheduled shows for the next 48 hours via user notice.  

## Live Announcements
dctvbot will announce channels when they go live or are reserved for upcoming events on [diamondclub.tv](https://diamondclub.tv). If that channel is an official one, dctvbot will also update the topic with the announcement.  

Sample upcoming announcement:  
![Live Announcement](https://dl.dropboxusercontent.com/u/18589646/dctvbot_announce_soon.png)  
Sample live announcement:  
![Live Announcement](https://dl.dropboxusercontent.com/u/18589646/dctvbot_announce_live.png)  
