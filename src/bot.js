import irc from 'irc'

export default class Bot {
  constructor (config) {
    this.config = config
  }

  start () {
    // IRC Client
    this.client = new irc.Client(this.config.server.address, this.config.bot.nick, {
      userName: this.config.bot.userName,
      realName: this.config.bot.realName,
      port: this.config.server.port,
        // debug: true,
      channels: this.config.server.channels
    })
  }
}
