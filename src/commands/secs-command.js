import Command from './command'

/**
 * SecsCommand class
 *
 * @export
 * @class SecsCommand
 * @extends {Command}
 */
export default class SecsCommand extends Command {
  /**
   * Creates an instance of SecsCommand
   *
   * @param {DCTVApi} dctvApi
   *
   * @memberOf SecsCommand
   */
  constructor (dctvApi) {
    super('secs', 'notice', true)
    this.dctvApi = dctvApi
  }

  /**
   * Responds to command
   *
   * @param {Array<string>} args
   * @param {string} nick
   * @returns {string}
   *
   * @memberOf SecsCommand
   */
  async getResponse (args, nick) {
    let response = 'Sorry, I didn\'t receive a command'
    if (args[0]) {
      response = await this.dctvApi.secondScreenRequest(args[0], nick)
    }
    return response
  }
}
