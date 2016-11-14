import request from 'request'
import { EventEmitter } from 'events'

const BASE_URL = 'http://diamondclub.tv/api'
const CHANNELS_URL = `${BASE_URL}/channelsv2.php`
const SECOND_SCREEN_URL = `${BASE_URL}/secondscreen.php`

const SECS_COMMANDS = ['on', 'off', 'clear']

const UPDATE_ASSIGNED_CHANNELS_SPEED = 3 * 1000

export default class DCTVApi extends EventEmitter {
  constructor (secsPro = '') {
    super()
    this.secsPro = secsPro
    this.assignedChannels = []
  }

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

  getNewChannels (oldChannels) {
    return this.assignedChannels.filter(liveCh => {
      let res = oldChannels.find(oldCh => {
        return (liveCh.streamid === oldCh.streamid && liveCh.yt_upcoming === oldCh.yt_upcoming)
      })
      return typeof res === 'undefined'
    })
  }

  getOfficialLive () {
    let officialLive = null
    for (let i = 0; i < this.assignedChannels.length; i++) {
      if (this.assignedChannels[i].channel === 1) {
        officialLive = this.assignedChannels[i]
      }
    }
    return officialLive
  }

  async updateAssignedChannels () {
    let oldChannels = this.assignedChannels
    let wasOfficialLive = Boolean(this.getOfficialLive())

    this.assignedChannels = await this.getAssignedChannels()

    let officialLive = this.getOfficialLive()
    if (wasOfficialLive !== Boolean(officialLive)) {
      this.emit('officialLive', officialLive)
    }

    let newChannels = this.getNewChannels(oldChannels)
    if (newChannels && newChannels.length > 0) {
      this.emit('newChannels', newChannels)
    }
  }

  start () {
    setInterval(() => { this.updateAssignedChannels() }, UPDATE_ASSIGNED_CHANNELS_SPEED)
  }
}
