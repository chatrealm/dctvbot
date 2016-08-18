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

/**
 * Processes incomming commands
 *
 * @param {string} text - message text
 * @param {string} nick - nick of the sender
 * @param {string} to - message recipient
 */
function processCommand(text, nick, to) {
    let channelsUrl = 'http://diamondclub.tv/api/channelsv2.php';
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
                        replyMsg += `\nChannel ${ch.channel}: ${ch.friendlyalias}`;
                    }
                }
                client.notice(replyTo, replyMsg);
            });
            break;
        case 'next':
            getGoogleCalendar('a5jeb9t5etasrbl6dt5htkv4to@group.calendar.google.com', function(events) {
                let replyMsg = `Next Scheduled Show: ${events[0].summary} - ${events[0].start.dateTime}`;
                client.notice(replyTo, replyMsg);
            });
            break;
        case 'schedule':
            getGoogleCalendar('a5jeb9t5etasrbl6dt5htkv4to@group.calendar.google.com', function(events) {
                let replyMsg = 'Scheduled Shows for the Next 48 hours:';
                for (let i = 0; i < events.length; i++) {
                    replyMsg += `\n${events[i].summary} - ${events[i].start.dateTime}`;
                }
                client.notice(replyTo, replyMsg);
            });
            break;
        default:
            console.log('default');
    }
}

/**
 * Callback for handling url response
 *
 * @callback urlCallback
 * @param {string} body
 */

/**
 * Gets contents of a URL
 *
 * @param {string} url - url to getDate
 * @param {urlCallback} callback - callback to run
 */
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

/**
 * Callback for handling google calendar items result
 *
 * @callback calendarEventsCallback
 * @param {JSON[]} entities
 */

/**
 * Gets google calendar items
 *
 * @param {string} id - google calendar id
 * @param {calendarEventsCallback} callback - callback to run
 */
function getGoogleCalendar(id, callback) {
    let now = new Date();
    let later = new Date();
    later.setDate(later.getDate() + 2);

    let url = `https://www.googleapis.com/calendar/v3/calendars/${id}/events` +
        `?key=${config.google.apiKey}&singleEvents=true&orderBy=startTime` +
        `&timeMin=${now.toISOString()}&timeMax=${later.toISOString()}`;
    getUrlContents(url, function(response) {
        let result = JSON.parse(response);
        callback(result.items);
    });
}
