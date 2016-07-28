var irc = require('irc');

var config = require('./config/config');

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
