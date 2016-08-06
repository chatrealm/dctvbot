// Load node libs
var irc = require('irc');

// Load custom libs
var handlers = require('./lib/handlers');

// Load config
var config = require('./config/config');

// IRC Client
var client = new irc.Client(
	config.server.address,
	config.bot.nick,
	{
		userName:	config.bot.userName,
		realName:	config.bot.realName,
		port: 		config.server.port,
		debug:		true,
		channels:	config.server.channels
	}
);

// Instantiate handlers instance
var handler = new handlers(client, config);

// Listen for messages
client.addListener('message', handler.message);
