import irc from 'irc';
import request from 'request';
import config from '../config/config';

// IRC Client
let client = new irc.Client(config.server.address, config.bot.nick, {
    userName: config.bot.userName,
    realName: config.bot.realName,
    port: config.server.port,
    debug: true,
    channels: config.server.channels
});

// Listen for messages
client.addListener('message', function(nick, to, text, message) {
    if (text.startsWith('!') || to === client.nick) {
        processCommand(text, nick, to);
    } else {
        console.log('not a command');
    }
});

function processCommand(text, nick, to) {
    let channelsUrl = 'http://diamondclub.tv/api/channelsv2.php';
    // let statusUrl = 'http://diamondclub.tv/api/statusv2.php';

    let cmd = text;

    let replyTo = to;
    if (to === client.nick) {
        replyTo = nick;
    } else {
        cmd = cmd.slice(1).trim();
    }

    switch (cmd) {
        case 'now':
            getUrlContents(channelsUrl, function(response) {
                let replyMsg = 'Nothing is live';
                let channels = JSON.parse(response).assignedchannels;

                if (channels.length !== null && channels.length > 0) {
                    replyMsg = '';
                    for (var i = 0; i < channels.length; i++) {
                        let ch = channels[i];
                        replyMsg += `\nChannel ${ch.channel}:` +
                            ` ${ch.friendlyalias}`;
                    }
                }
                client.notice(replyTo, replyMsg);
            });
            break;
        case 'next':
            console.log(getGoogleCalendar('a5jeb9t5etasrbl6dt5htkv4to@group.calendar.google.com'));
            break;
        default:
            console.log('default');
    }
}

function getUrlContents(url, callback) {
    request(url, function(error, response, body) {
        if (!error && response.statusCode === 200) {
            if (body === null) {
                console.error(`Error: ${response}`);
            } else {
                callback(body);
            }
        } else {
            console.error(`Error: ${error}`);
        }
    });
}

function getGoogleCalendar(id, callback) {
    let now = Date.now();
    let url = 'https://www.googleapis.com/calendar/v3/calendars' +
        `?key=${config.google.apiKey}&singleEvents=true&orderBy=startTime` +
        `&timeMin=${now}&timeMax=${now + (2 * 24 * 60 * 60)}` +
        `${id}/events`;
    return getUrlContents(url);
}
