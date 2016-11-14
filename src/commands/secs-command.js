import Command from './command'

export default class SecsCommand extends Command {
  constructor (dctv) {
    super('secs', 'notice', true)
    this.dctv = dctv
  }

  async getResponse (args, nick) {
    let response = 'Sorry, I didn\'t receive a command'
    if (args[0]) {
      response = await this.dctv.secondScreenRequest(args[0], nick)
    }
    return response
  }
}
