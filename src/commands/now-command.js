import Command from './command'

export default class NowCommand extends Command {
  constructor (dctvApi) {
    super('now', 'authorize', false)
    this.dctvApi = dctvApi
  }

  async getResponse (args, nick) {
    let reply = 'Nothing is live right now'
    if (this.dctvApi.assignedChannels.length > 0) {
      reply = 'Here\'s what\'s currently live:'
      for (let i = 0; i < this.dctvApi.assignedChannels.length; i++) {
        let ch = this.dctvApi.assignedChannels[i]
        reply += `\nChannel ${ch.channel}: ${ch.friendlyalias} - ${ch.urltoplayer}`
      }
    }
    return reply
  }
}
