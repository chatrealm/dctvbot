import request from 'request';

const CHANNELS_URL = 'http://diamondclub.tv/api/channelsv2.php';

export default {
    liveChannels: [],
    updateLiveChannels() {
        request(CHANNELS_URL, (error, response, body) => {
            if (!error && response.statusCode === 200) {
                if (body === null) {
                    console.error(`Error: ${response}`);
                } else {
                    this.liveChannels = response.assignedchannels;
                }
            } else {
                console.error(`Error: ${error}`);
            }
        });
    }
};

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
