/**
 * Command base class
 *
 * @export
 * @class Command
 */
export default class Command {
  /**
   * Creates an instance of Command
   *
   * @param {string} word
   * @param {string} [outputTo='authorize']
   * @param {boolean} [needAuthorization=false]
   *
   * @memberOf Command
   */
  constructor (word, outputTo = 'authorize', needAuthorization = false) {
    this.word = word
    this.outputTo = outputTo
    this.needAuthorization = needAuthorization
  }

  /**
   * Responds to command
   *
   * @param {Array<string>} args
   * @param {string} nick
   *
   * @memberOf Command
   */
  async getResponse (args, nick) {
    throw Error('respond method not implemented')
  }
}
