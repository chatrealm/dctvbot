import irc from 'irc'

/** Class for main bot */
export default class Bot {
  /**
   * Create a bot instance
   * @param {object} config - Configuration object
   */
  constructor (config) {
    this.config = config
  }

  /**
   * Kicks off bot
   */
  start () {
    // Set IRC Client
    this.client = new irc.Client(this.config.server.address, this.config.bot.nick, {
      userName: this.config.bot.userName,
      realName: this.config.bot.realName,
      port: this.config.server.port,
      // debug: true,
      channels: this.config.server.channels
    })
  }
}
