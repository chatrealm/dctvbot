import Irc from 'irc';
import Config from '../config/config';

// IRC Client
var client = new Irc.Client(
    Config.server.address,
    Config.bot.nick, {
        userName: Config.bot.userName,
        realName: Config.bot.realName,
        port: Config.server.port,
        debug: true,
        channels: Config.server.channels
    }
);

// Listen for messages
client.addListener('message', function(nick, to, text, message) {

});
