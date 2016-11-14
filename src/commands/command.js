export default class Command {
  constructor (word, outputTo = 'authorize', needAuthorization = false) {
    this.word = word
    this.outputTo = outputTo
    this.needAuthorization = needAuthorization
  }

  async getResponse (args, nick) {
    throw Error('respond method not implemented')
  }
}
