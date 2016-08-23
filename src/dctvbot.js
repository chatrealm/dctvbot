import irc from 'irc';
import colors from 'irc-colors';
import request from 'request';
import config from './config/config';

/**
 * Gets contents of a URL
 * @param {string} url - url to getDate
 * @param {function(string): void} callback - Callback for handling url response
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
 * Gets DCTV live channels
 * @param {function(Channel[]): void} callback - Callback for handling DCTV live channels
 */
function getDctvLiveChannels(callback) {
    let channelsUrl = 'http://diamondclub.tv/api/channelsv2.php';
    getUrlContents(channelsUrl, function(response) {
        callback(JSON.parse(response).assignedchannels);
    });
}

/**
 * Gets google calendar items
 * @param {string} id - google calendar id
 * @param {function(Object[]): void} callback - Callback for handling google calendar items result
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

// IRC Client
let client = new irc.Client(config.server.address, config.bot.nick, {
    userName: config.bot.userName,
    realName: config.bot.realName,
    port: config.server.port,
    debug: true,
    channels: config.server.channels
});

/**
 * Processes incoming commands
 * @param {string} text - message text
 * @param {string} nick - nick of the sender
 * @param {string} to - message recipient
 */
function processCommand(text, nick, to) {
    let cmd = text;

    let replyTo = to;
    if (to === client.nick) {
        replyTo = nick;
    } else {
        cmd = cmd.slice(1).trim();
    }

    switch (cmd) {
        case 'now':
            getDctvLiveChannels(function(channels) {
                let replyMsg = 'Nothing is live';
                if (channels.length > 0) {
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
            getGoogleCalendar(config.google.calendarId, function(events) {
                // TODO: time sentance representation
                let replyMsg = `Next Scheduled Show: ${events[0].summary} - ${events[0].start.dateTime}`;
                client.notice(replyTo, replyMsg);
            });
            break;
        case 'schedule':
            getGoogleCalendar(config.google.calendarId, function(events) {
                let replyMsg = 'Scheduled Shows for the Next 48 hours:';
                for (let i = 0; i < events.length; i++) {
                    // TODO: time.is date/time link
                    replyMsg += `\n${events[i].summary} - ${events[i].start.dateTime}`;
                }
                client.notice(replyTo, replyMsg);
            });
            break;
        default:
            console.log('default');
    }
}

// Listen for messages
client.addListener('message', function(nick, to, text, message) {
    if (text.startsWith('!') || to === client.nick) {
        processCommand(text, nick, to);
    } else {
        // console.log('not a command');
    }
});

let liveChannels = '-1';
let currentTopic = '';

// Listen for topic changes
client.addListener('topic', function(channel, topic, nick, message) {
    currentTopic = topic;
});

function updateTopic(newText) {
    const separator = ' | ';
    let topicArray = currentTopic.split(separator);
    topicArray[0] = newText;
    client.send('TOPIC', config.server.channels[0], topicArray.join(separator));
}

function announceNewLiveChannel(ch, officialLive) {
    let msg = ch.yt_upcoming ? colors.black.bgyellow(' NEXT ') : colors.white.bgred(' LIVE ');
    msg += ` ${ch.friendlyalias}`;
    if (ch.twitch_yt_description !== '') {
        msg += ` - ${ch.twitch_yt_description}`;
    }
    if (ch.channel === 1) {
        updateTopic(msg);
    } else if (!officialLive) {
        client.say(config.server.channels[0], msg);
    }
}

let firstRun = false;

/**
 * Scans DCTV for channel updates to relay to the IRC channel
 */
function scanForChannelUpdates() {
    if (liveChannels === "-1") {
        firstRun = true;
        liveChannels = [];
    }

    getDctvLiveChannels(function(channels) {
        let prevChannels = liveChannels;
        liveChannels = [];
        for (let i = 0; i < channels.length; i++) {
            let ch = channels[i];
            if (ch.nowonline === 'yes' || ch.yt_upcoming) {
                liveChannels.push(ch);
            }
        }

        if (!firstRun) {
            let officialLive = false;
            for (let i = 0; i < liveChannels.length; i++) {
                if (liveChannels[i].channel === 1) {
                    officialLive = true;
                }
            }

            if (!officialLive && !currentTopic.startsWith(' <>')) {
                updateTopic(' <>');
            }

            let newLive = liveChannels.find(function(liveCh) {
                let res = prevChannels.find(function(prevCh) {
                    return liveCh.streamid === prevCh.streamid;
                });
                return typeof res === 'undefined';
            });

            if (typeof newLive !== 'undefined') {
                announceNewLiveChannel(newLive, officialLive);
            }
        }

        firstRun = false;
    });
}

setInterval(scanForChannelUpdates, 5000);

// Additional documentation

/**
 * DCTV Channel Object, response from api
 * @typedef Channel
 * @type {object}
 * @property {number} streamid - Unique ID of stream
 * @property {string} channelname - Channel name
 * @property {string} friendlyalias - Display name for channel
 * @property {string} streamtype - Stream type indicator, one of: "twitch", "rtmp-hls", "youtube", or "override"
 * @property {string} nowonline - Online status, one of: "yes" or "no"
 * @property {boolean} alerts - Indicator for if a channel wants alerts when going live
 * @property {string} twitch_currentgame - If {@link streamtype} is "twitch", this will contain the game the user has set
 * @property {string} twitch_yt_description - If {@link streamtype} is either "twitch" or "youtube", this will contain the description the user has set
 * @property {boolean} yt_upcoming - If {@link streamtype} is "youtube", this will contain the 'upcoming' status of a live broadcast
 * @property {string} yt_liveurl - If {@link streamtype} is "youtube", this will contain a youtube url to the live stream
 * @property {string} imageasset - Url to SD image for channel
 * @property {string} imageassethd - Url to HD image for channel
 * @property {string} urltoplayer - Url to DCTV channel
 * @property {number} channel - The channel's number
 */
