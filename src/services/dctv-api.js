import request from 'request'
import { EventEmitter } from 'events'

const BASE_URL = 'http://diamondclub.tv/api'
const CHANNELS_URL = `${BASE_URL}/channelsv2.php`
const SECOND_SCREEN_URL = `${BASE_URL}/secondscreen.php`

const SECS_COMMANDS = ['on', 'off', 'clear']

const UPDATE_ASSIGNED_CHANNELS_SPEED = 3 * 1000

/**
 * DCTVApi class
 *
 * @export
 * @class DCTVApi
 * @extends {EventEmitter}
 */
export default class DCTVApi extends EventEmitter {
  /**
   * Creates an instance of DCTVApi
   *
   * @param {string} [secsPro='']
   *
   * @memberOf DCTVApi
   */
  constructor (secsPro = '') {
    super()
    this.secsPro = secsPro
    this.assignedChannels = []
  }

  /**
   * Executes second screen request
   *
   * @param {string} input
   * @param {string} nick
   * @returns {PromiseLike<string>}
   *
   * @memberOf DCTVApi
   */
  secondScreenRequest (input, nick) {
    return new Promise((resolve, reject) => {
      if (!this.secsPro) {
        resolve('Missing SecsPro value')
        return
      }
      if (!input.startsWith('http') && SECS_COMMANDS.indexOf(input) === -1) {
        resolve('INVALID SELECTION')
        return
      }
      let url = `${SECOND_SCREEN_URL}?url=${input}&user=${nick}&pro=${this.secsPro}`
      request(url, (error, response, body) => {
        if (error) {
          reject(error)
          return
        }
        resolve(`Command Sent. Response: ${body}`)
      })
    })
  }

  /**
   * Gets assigned channels list from dctv api
   *
   * @returns {PromiseLike<Array<Object>>}
   *
   * @memberOf DCTVApi
   */
  getAssignedChannels () {
    return new Promise((resolve, reject) => {
      request(CHANNELS_URL, (error, response, body) => {
        if (error) {
          reject(error)
          return
        }
        resolve(JSON.parse(body).assignedchannels)
      })
    })
  }

  /**
   * Filters assigned channels against `oldChannels` to return only new assigned channels
   *
   * @param {Array<Object>} oldChannels
   * @returns {Array<Object>}
   *
   * @memberOf DCTVApi
   */
  getNewChannels (oldChannels) {
    return this.assignedChannels.filter(liveCh => {
      let res = oldChannels.find(oldCh => {
        return (liveCh.streamid === oldCh.streamid && liveCh.yt_upcoming === oldCh.yt_upcoming)
      })
      return typeof res === 'undefined'
    })
  }

  /**
   * Gets stream currently assigned to channel 1
   *
   * @returns {Object}
   *
   * @memberOf DCTVApi
   */
  getOfficialLive () {
    let officialLive = null
    for (let i = 0; i < this.assignedChannels.length; i++) {
      if (this.assignedChannels[i].channel === 1) {
        officialLive = this.assignedChannels[i]
      }
    }
    return officialLive
  }

  /**
   * Updates instance assigned channels list and emits events as needed
   *
   * @memberOf DCTVApi
   */
  async updateAssignedChannels () {
    let oldChannels = this.assignedChannels
    let wasOfficialLive = this.getOfficialLive()

    this.assignedChannels = await this.getAssignedChannels()

    let officialLive = this.getOfficialLive()

    if ((Boolean(wasOfficialLive) !== Boolean(officialLive)) ||
      ((wasOfficialLive && officialLive) && (wasOfficialLive.yt_upcoming !== officialLive.yt_upcoming))) {
      this.emit('officialLive', officialLive)
    }

    let newChannels = this.getNewChannels(oldChannels)
    if (newChannels && newChannels.length > 0) {
      this.emit('newChannels', newChannels)
    }
  }

  /**
   * Starts a timer to update assigned channels list on
   *
   * @memberOf DCTVApi
   */
  start () {
    setInterval(() => { this.updateAssignedChannels() }, UPDATE_ASSIGNED_CHANNELS_SPEED)
  }
}
