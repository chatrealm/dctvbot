var irc = require('irc');

var config = {
	// Bot config
	bot: {
		nick: 'testbot',
		userName: 'node',
		realName: 'node bot'
	},
	// Server config
	server: {
		address: 'irc.chatrealm.net',
		port: 6667,
		channels: [ '#testbot' ]
	},
	// General config
};

// IRC Client
var client = new irc.Client(
	config.server.address,
	config.bot.nick,
	{
		userName: config.bot.userName,
		realName: config.bot.realName,
		port: config.server.port,
		debug: true,
		channels: config.server.channels
	}
);
