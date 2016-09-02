import irc from 'irc';
import colors from 'irc-colors';
import moment from 'moment-timezone';

import googleCalendar from './services/google-calendar';
import dctvApi from './services/dctv-api';

import config from './config/config';

let currentDctvChannels = '-1';
let currentTopic = '';
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
client.addListener('registered', message => {
    if (config.bot.password) {
        client.say('NickServ', `IDENTIFY ${config.bot.password}`);
    }
});

// Listen for messages in channels
client.addListener('message#', (nick, to, text, message) => {
    if (text.startsWith(config.prefix)) {
        processCommand(text.slice(1).trim(), to, nick);
    } else {
        // console.log('not a command');
    }
});

// Listen for PMs
client.addListener('pm', (nick, text, message) => {
    processCommand(text.trim(), null, nick);
});

// Listen for topic changes
client.addListener('topic', (channel, topic, nick, message) => {
    currentTopic = topic;
});

// Ask for names update for all channels every 60 sec
setInterval(() => {
    for (let i = 0; i < config.server.channels.length; i++) {
        client.send('NAMES', config.server.channels[i]);
    }
}, 60000);

// Listen for name list events
client.addListener('names', (channel, nicks) => {
    ircChannelsNicks[channel] = nicks;
});

// Update DCTV Live Channels every 5 sec
setInterval(dctvApi.updateLiveChannels, 5000);

// Check live announcements every 3 sec
setInterval(checkForLiveAnnouncements, 3000);

/**
 * Checks for 'admin' privelage, hard coded to voiced or better for now
 * @param {string} nick - nick of requestor
 * @param {string} channel - channel permissions were requested in
 * @return {boolean} - do they have the power?
 */
function hasThePower(nick, channel) {
    const adminModes = ['~', '@', '%', '+'];
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
 */
function processCommand(cmd, channel, nick) {
    let cmdParts = cmd.split(' ');
    if (cmdParts.length > 1) {
        cmd = cmdParts[0];
    }
    let wantLoud = cmdParts[1] === 'v';

    let replyMsg = '';

    switch (cmd) {
        case 'now':
            replyMsg = 'Nothing is live';
            if (dctvApi.liveChannels.length > 0) {
                replyMsg = '';
                for (var i = 0; i < dctvApi.liveChannels.length; i++) {
                    let ch = dctvApi.liveChannels[i];
                    replyMsg += `\nChannel ${ch.channel}: ${ch.friendlyalias} - ${ch.urltoplayer}`;
                }
            }
            replyToCommand(replyMsg, channel, nick, wantLoud);
            break;
        case 'next':
            googleCalendar.getFromConfig(events => {
                let replyMsg = `Next Scheduled Show: ${events[0].summary} - ${moment().to(events[0].start.dateTime)}`;
                replyToCommand(replyMsg, channel, nick, wantLoud);
            });
            break;
        case 'schedule':
            googleCalendar.getFromConfig(events => {
                let replyMsg = 'Scheduled Shows for the Next 48 hours:';
                for (let i = 0; i < events.length; i++) {
                    let showDate = moment(events[i].start.dateTime).tz(moment.tz.guess());
                    let timeIsLink = `http://time.is/${showDate.format('HHmm_DD_MMM_YYYY_zz')}`;
                    replyMsg += `\n${events[i].summary} - ${timeIsLink}`;
                }
                replyToCommand(replyMsg, channel, nick, wantLoud);
            });
            break;
        case 'secs':
            if (hasThePower(nick, channel)) {
                if (typeof cmdParts[1] !== 'undefined') {
                    dctvApi.secondScreenRequest(cmdParts[1], nick, response => {
                        replyToCommand(response, channel, nick);
                    });
                }
            } else {
                replyToCommand('You have insufficient priveleges.', channel, nick);
            }
            break;
        default:
            console.log('default');
    }
}

/**
 * Appropriately replies to a command
 * @param {string} msg - message to send
 * @param {string} channel - channel command was in
 * @param {string} nick - nick of user that sent command
 * @param {boolean} requestLoud - if user wants to not use notice in channel
 */
function replyToCommand(msg, channel, nick, requestLoud = false) {
    if (channel === null) {
        client.say(nick, msg);
    } else if (requestLoud && hasThePower(nick, channel)) {
        client.say(channel, msg);
    } else {
        client.notice(nick, msg);
    }
}

/**
 * Scans DCTV for channel updates to relay to the IRC channel
 */
function checkForLiveAnnouncements() {
    let firstRun = false;

    if (currentDctvChannels === '-1') {
        firstRun = true;
        currentDctvChannels = [];
    }

    let prevDctvChannels = currentDctvChannels;
    currentDctvChannels = [];
    for (let i = 0; i < dctvApi.liveChannels.length; i++) {
        let ch = dctvApi.liveChannels[i];
        if (ch.nowonline === 'yes' || ch.yt_upcoming) {
            currentDctvChannels.push(ch);
        }
    }

    if (!firstRun) {
        let wasOfficialLive = officialLive;
        officialLive = false;
        for (let i = 0; i < currentDctvChannels.length; i++) {
            if (currentDctvChannels[i].channel === 1) {
                officialLive = true;
            }
        }

        if (wasOfficialLive && !officialLive) { // && !currentTopic.startsWith(' <>')
            updateTopic(' <>', config.server.channels[0]);
        }

        let newLive = currentDctvChannels.find(liveCh => {
            let res = prevDctvChannels.find(prevCh => {
                return (liveCh.streamid === prevCh.streamid &&
                    liveCh.yt_upcoming === prevCh.yt_upcoming);
            });
            return typeof res === 'undefined';
        });

        if (typeof newLive !== 'undefined') {
            announceNewLiveChannel(newLive, config.server.channels[0]);
        }
    }
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
