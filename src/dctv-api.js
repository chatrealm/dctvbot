/** Class for DCTV API */
export default class DctvApi {
  constructor (config) {
    this.config = config
  }
}




// import request from 'request'
// import config from '../config/config'

// const BASE_URL = 'http://diamondclub.tv/api'
// const CHANNELS_URL = `${BASE_URL}/channelsv2.php`
// const SECOND_SCREEN_URL = `${BASE_URL}/secondscreen.php`

// export default {
//   updateLiveChannels (callback) {
//     request(CHANNELS_URL, (error, response, body) => {
//       if (!error && response.statusCode === 200) {
//         if (body === null) {
//           console.error(`Error: ${response}`)
//         } else {
//           callback(JSON.parse(body).assignedchannels)
//         }
//       } else {
//         console.error(`Error: ${error}`)
//       }
//     })
//   },

//   secondScreenRequest (input, nick, callback) {
//     const KNOWN_COMMANDS = ['on', 'off', 'clear']
//     if (input.startsWith('http') || KNOWN_COMMANDS.indexOf(input) !== -1) {
//       request(`${SECOND_SCREEN_URL}?url=${input}&user=${nick}&pro=${config.dctv.apiSecsPro}`, (error, response, body) => {
//         if (!error && response.statusCode === 200) {
//           if (body === null) {
//             console.error(`Error: ${response}`)
//           } else {
//             callback(`Command Sent. Response: ${body}`)
//           }
//         } else {
//           console.error(`Error: ${error}`)
//         }
//       })
//     } else {
//       callback('Invalid Selection')
//     }
//   }
// }

/**
 * DCTV Channel Object
 *
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
