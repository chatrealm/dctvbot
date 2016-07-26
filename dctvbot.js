var irc = require('irc');

var config = {
	// Server config
	server: {
		host: 'irc.chatrealm.net',
		channels: [ '#testbot' ]
	},
	// Bot config
	bot: {
		nick: 'testbot'
	}
};

// IRC Client
var client = new irc.Client(
	config.server.host,
	config.bot.nick,
	{ channels: config.server.channels }
);
