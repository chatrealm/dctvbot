function handlers(client, config) {

	var cmdRegex = new RegExp('^' + config.prefix + '(.+)');
	var chanRegex = new RegExp('#.+');

	var reply = function(message, target, notice) {
		if (notice) {
			client.notice(target, message);
		} else {
			client.say(target, message);
		}
	};

	this.message = function (nick, to, text, message) {
		var command = cmdRegex.exec(text);
		var replyTo = nick;

		if (to == client.nick) {
			// PM, command is probably just the text
			command = text;
		} else if (Array.isArray(command)) {
			// Standard message, command comes after prefix
			command = command[1];
		} else {
			// Something else...abort
			command = null;
		}

		if (command) {
			// Act on command
			if (chanRegex.exec(to)) { replyTo = to; }
			reply(command, replyTo);
		}
	};

}

module.exports = handlers;
