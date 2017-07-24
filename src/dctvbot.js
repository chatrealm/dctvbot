import irc from 'irc'
import colors from 'irc-colors'
import Cleverbot from 'cleverbot-node'

import NextCommand from './commands/next-command'
import NowCommand from './commands/now-command'
import ScheduleCommand from './commands/schedule-command'
import SecsCommand from './commands/secs-command'

const ADMIN_MODES = ['~', '@', '%', '+']
const BOT_NICK = 'dctvbot'
const CMD_PREFIX = '!'
const DEFAULT_TOPIC_FIRST_ITEM = ' <>'
const IRC_SERVER = 'irc.chatrealm.net'
const TOPIC_SEPARATOR = ' | '

/**
 * DCTVBot Class
 *
 * @export
 * @class DCTVBot
 */
export default class DCTVBot {
  /**
   * Creates an instance of DCTVBot
   *
   * @param {Array<Object>} [ircChannelNames=[]]
   * @param {string} [ircPassword='']
   * @param {DCTVApi} [dctvApi=null]
   * @param {GoogleCalendar} [gcal=null]
   *
   * @memberOf DCTVBot
   */
  constructor (ircChannelNames = [], ircPassword = '', dctvApi = null, gcal = null) {
    this.ircChannelNames = ircChannelNames
    this.ircPassword = ircPassword
    this.dctvApi = dctvApi

    this.ircCommands = []
    if (this.dctvApi) {
      this.ircCommands.push(new NowCommand(this.dctvApi))
      if (this.dctvApi.secsPro) {
        this.ircCommands.push(new SecsCommand(this.dctvApi))
      }
    }
    if (gcal) {
      this.ircCommands.push(
        new NextCommand(gcal),
        new ScheduleCommand(gcal)
      )
    }

    this.ircClient = new irc.Client(IRC_SERVER, BOT_NICK, {
      autoConnect: false,
      debug: false
    })

    this.cleverbot = new Cleverbot()
    this.officialLive = false
  }

  /**
   * Registers listeners, starts timed components and irc connection
   *
   * @memberOf DCTVBot
   */
  start () {
    this.ircClient.on('registered', () => {
      if (this.ircPassword) {
        this.ircClient.say('NickServ', `IDENTIFY ${this.ircPassword}`)
      }

      let joinedIrcChannels = 0
      this.ircChannelNames.forEach(channelName => {
        this.ircClient.join(channelName, (nick, raw) => {
          joinedIrcChannels++
        })
      }, this)
    })

    this.ircCommands.forEach(command => {
      this.addCommandListener(command)
    })

    if (this.dctvApi) {
      this.dctvApi.on('officialLive', officialLiveChannel => {
        let wasOfficialLive = this.officialLive
        this.officialLive = Boolean(officialLiveChannel)
        let newText = DEFAULT_TOPIC_FIRST_ITEM
        if ((!wasOfficialLive && this.officialLive) || (officialLiveChannel && !officialLiveChannel.yt_upcoming)) {
          newText = this.formatAnnouncementMessage(officialLiveChannel)
        }
        for (let ircChannel in this.ircClient.chans) {
          let topic = this.ircClient.chans[ircChannel].topic
          if (!topic) {
            continue;
          }
          let pipeArray = topic.split(TOPIC_SEPARATOR)
          pipeArray[0] = newText
          this.ircClient.send('TOPIC', ircChannel, pipeArray.join(TOPIC_SEPARATOR))
        }
      })

      this.dctvApi.on('newChannels', newChannels => {
        if (!this.officialLive) {
          newChannels.forEach(newChannel => {
            let message = this.formatAnnouncementMessage(newChannel)
            for (let ircChannel in this.ircClient.chans) {
              this.reply(ircChannel, message, false)
            }
          }, this)
        }
      })

      this.dctvApi.start()
    }

    this.ircClient.addListener('message#', (nick, to, text, raw) => {
      if (text.startsWith(CMD_PREFIX)) {
        this.fireCommandEvent(text.slice(1).trim(), nick, to)
      } else if (text.startsWith(this.ircClient.nick)) {
        Cleverbot.prepare(() => {
          let regex = new RegExp(`${this.ircClient.nick}[:,]?`, 'g')
          let msg = text.replace(regex, '').trim()

          this.cleverbot.write(msg, response => {
            this.reply(to, `${nick}: ${response.message}`, false)
          })
        })
      } else {
        // console.log(raw)
      }
    })

    this.ircClient.addListener('pm', (nick, text, raw) => {
      this.fireCommandEvent(text.trim(), nick, null)
    })

    this.ircClient.connect()
  }

  /**
   * Formats announcement message with irc colors
   *
   * @param {Object} channel
   * @returns {string}
   *
   * @memberOf DCTVBot
   */
  formatAnnouncementMessage (channel) {
    let message = channel.yt_upcoming
                ? colors.black.bgyellow(' NEXT ')
                : colors.white.bgred(' LIVE ')
    message += ` ${channel.friendlyalias}`
    if (channel.twitch_yt_description) {
      message += ` - ${channel.twitch_yt_description}`
    }
    return `${message} - ${channel.urltoplayer}`
  }

  /**
   * Replies to `target` with `message`
   *
   * @param {string} target
   * @param {string} message
   * @param {boolean} [notice=true]
   *
   * @memberOf DCTVBot
   */
  reply (target, message, notice = true) {
    if (notice) {
      this.ircClient.notice(target, message)
    } else {
      this.ircClient.say(target, message)
    }
  }

  /**
   * Adds listener for `command`
   *
   * @param {Object} command
   *
   * @memberOf DCTVBot
   */
  addCommandListener (command) {
    this.ircClient.on(`${command.word}Command`, (nick, channel, args) => {
      let hasThePower = false
      if (channel) {
        let userModes = this.ircClient.chans[channel].users[nick]
        ADMIN_MODES.forEach(mode => {
          if (userModes.indexOf(mode) > -1) {
            hasThePower = true
          }
        })
      } else if (!command.needAuthorization) {
        hasThePower = true
      }

      if (command.needAuthorization && !hasThePower) {
        this.reply(nick, `I'm sorry, ${nick}. I'm afraid I can't do that.`, Boolean(channel))
        return
      }

      let notice = Boolean(channel)
      let target = nick
      switch (command.outputTo) {
        case 'authorize':
          if (args.length > 0 && args[0] === 'v' && hasThePower) {
            notice = false
            target = channel || nick
            args.shift()
          }
          break
        case 'channel':
          notice = false
          target = channel || nick
          break
        default:
          notice = Boolean(channel)
      }
      command.getResponse(args, nick).then(response => {
        this.reply(target, response, notice)
      })
    })
  }

  /**
   * Emits event for `command` sent by `nick` in `channel`
   *
   * @param {string} command
   * @param {string} nick
   * @param {string} channel
   *
   * @memberOf DCTVBot
   */
  fireCommandEvent (command, nick, channel) {
    let commandParts = command.split(' ')
    if (commandParts.length > 1) {
      command = commandParts.shift()
    }
    this.ircClient.emit(`${command}Command`, nick, channel, commandParts)
  }
}
