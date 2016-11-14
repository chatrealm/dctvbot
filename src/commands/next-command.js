import moment from 'moment-timezone'
import Command from './command'

export default class NextCommand extends Command {
  constructor (gcal) {
    super('next', 'channel', false)
    this.gcal = gcal
  }

  async getResponse (args, nick) {
    let now = new Date()
    let later = new Date()
    later.setDate(now.getDate() + 2)

    let reply = 'There are no scheduled shows for the next 2 days'
    let events = await this.gcal.getEvents(now, later)
    if (events.length > 0) {
      let event = events[0]
      let i = 0
      while (moment(event.start.dateTime).isBefore()) {
        i++
        event = events[i]
      }
      reply = `${event.summary} will be on in about ${moment().to(event.start.dateTime, true)}`
    }
    return reply
  }
}
