import irc from 'irc';
import colors from 'irc-colors';
import request from 'request';
import moment from 'moment-timezone';
import config from './config/config';

let liveDctvChannels = '-1';
let currentTopic = '';
let firstRun = false;
let officialLive = false;
let ircChannelsNicks = [];

// IRC Client
let client = new irc.Client(config.server.address, config.bot.nick, {
    userName: config.bot.userName,
    realName: config.bot.realName,
    port: config.server.port,
    debug: true,
    channels: config.server.channels
});

// Listen for registered events
client.addListener('registered', function(message) {
    if (config.bot.password) {
        client.say('NickServ', `IDENTIFY ${config.bot.password}`);
    }
});

// Listen for messages in channels
client.addListener('message#', function(nick, to, text, message) {
    if (text.startsWith('!')) {
        processCommand(text.slice(1).trim(), to, nick, to);
    } else {
        // console.log('not a command');
    }
});

// Listen for PMs
client.addListener('pm', function(nick, text, message) {
    processCommand(text, null, nick, nick);
});

// Listen for topic changes
client.addListener('topic', function(channel, topic, nick, message) {
    currentTopic = topic;
});

// Ask for names update for all channels every 60 sec
setInterval(function() {
    for (let i = 0; i < config.server.channels.length; i++) {
        client.send('NAMES', config.server.channels[i]);
    }
}, 60000);

// Listen for name list events
client.addListener('names', function(channel, nicks) {
    ircChannelsNicks[channel] = nicks;
});

setInterval(scanForChannelUpdates, 5000);

/**
 * Checks for 'admin' privelage
 * @param {string} nick - nick of requestor
 * @param {string} channel - channel permissions were requested in
 * @return {boolean} - do they have the power?
 */
function hasThePower(nick, channel) {
    let adminModes = ['~', '@', '%', '+'];
    let userModes = ircChannelsNicks[channel][nick];

    for (let i = 0; i < adminModes.length; i++) {
        if (userModes.indexOf(adminModes[i]) > -1) {
            return true;
        }
    }
    return false;
}

/**
 * Processes incoming commands
 * @param {string} cmd - command text
 * @param {string} channel - channel the command was sent to (null if pm)
 * @param {string} nick - nick that sent command
 * @param {string} replyTo - reply target
 */
function processCommand(cmd, channel, nick, replyTo) {
    let cmdParts = cmd.split(' ');
    if (cmdParts.length > 1) {
        cmd = cmdParts[0];
    }

    let wantLoud = cmdParts[1] === 'v';

    switch (cmd) {
        case 'now':
            getDctvLiveChannels(function(channels) {
                let replyMsg = 'Nothing is live';
                if (channels.length > 0) {
                    replyMsg = '';
                    for (var i = 0; i < channels.length; i++) {
                        let ch = channels[i];
                        replyMsg += `\nChannel ${ch.channel}: ${ch.friendlyalias} - ${ch.urltoplayer}`;
                    }
                }
                replyToCommand(replyMsg, replyTo, channel, nick, wantLoud);
            });
            break;
        case 'next':
            getGoogleCalendar(config.google.calendarId, function(events) {
                let replyMsg = `Next Scheduled Show: ${events[0].summary} - ${moment().to(events[0].start.dateTime)}`;
                replyToCommand(replyMsg, replyTo, channel, nick, wantLoud);
            });
            break;
        case 'schedule':
            getGoogleCalendar(config.google.calendarId, function(events) {
                let replyMsg = 'Scheduled Shows for the Next 48 hours:';
                for (let i = 0; i < events.length; i++) {
                    let showDate = moment(events[i].start.dateTime).tz(moment.tz.guess());
                    let timeIsLink = `http://time.is/${showDate.format('HHmm_DD_MMM_YYYY_zz')}`;
                    replyMsg += `\n${events[i].summary} - ${timeIsLink}`;
                }
                replyToCommand(replyMsg, replyTo, channel, nick, wantLoud);
            });
            break;
        default:
            console.log('default');
    }
}

/**
 * Appropriately replies to a command
 * @param {string} msg - message to send
 * @param {string} target - reply target
 * @param {string} channel - channel command was in
 * @param {string} nick - nick of user that sent command
 * @param {boolean} requestLoud - if user wants to not use notice in channel
 */
function replyToCommand(msg, target, channel, nick, requestLoud) {
    if (channel === null || (requestLoud && hasThePower(nick, channel))) {
        client.say(target, msg);
    } else {
        client.notice(target, msg);
    }
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
 * Scans DCTV for channel updates to relay to the IRC channel
 */
function scanForChannelUpdates() {
    if (liveDctvChannels === '-1') {
        firstRun = true;
        liveDctvChannels = [];
    }

    getDctvLiveChannels(function(channels) {
        let prevChannels = liveDctvChannels;
        liveDctvChannels = [];
        for (let i = 0; i < channels.length; i++) {
            let ch = channels[i];
            if (ch.nowonline === 'yes' || ch.yt_upcoming) {
                liveDctvChannels.push(ch);
            }
        }

        if (!firstRun) {
            let wasOfficialLive = officialLive;
            officialLive = false;
            for (let i = 0; i < liveDctvChannels.length; i++) {
                if (liveDctvChannels[i].channel === 1) {
                    officialLive = true;
                }
            }

            if (wasOfficialLive && !officialLive) { // && !currentTopic.startsWith(' <>')
                updateTopic(' <>', config.server.channels[0]);
            }

            let newLive = liveDctvChannels.find(function(liveCh) {
                let res = prevChannels.find(function(prevCh) {
                    return (liveCh.streamid === prevCh.streamid &&
                        liveCh.yt_upcoming === prevCh.yt_upcoming);
                });
                return typeof res === 'undefined';
            });

            if (typeof newLive !== 'undefined') {
                announceNewLiveChannel(newLive, config.server.channels[0]);
            }
        }

        firstRun = false;
    });
}

/**
 * Makes channel announcement
 * @param {Channel} ch - channel to announce
 * @param {string} ircChannel - irc channel to make announcement in
 */
function announceNewLiveChannel(ch, ircChannel) {
    let msg = ch.yt_upcoming ? colors.black.bgyellow(' NEXT ') : colors.white.bgred(' LIVE ');
    msg += ` ${ch.friendlyalias}`;

    if (ch.twitch_yt_description !== '') {
        msg += ` - ${ch.twitch_yt_description}`;
    }

    msg += ` - ${ch.urltoplayer}`;

    if (ch.channel === 1) {
        updateTopic(msg, ircChannel);
    } else if (!officialLive) {
        client.say(ircChannel, msg);
    }
}

/**
 * Updates first portion of topic with new info
 * @param {string} newText - New text for first section of topic
 * @param {string} ircChannel - irc channel to update topic in
 */
function updateTopic(newText, ircChannel) {
    const separator = ' | ';
    let topicArray = currentTopic.split(separator);
    topicArray[0] = newText;
    client.send('TOPIC', ircChannel, topicArray.join(separator));
}

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
