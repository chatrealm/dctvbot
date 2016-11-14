import moment from 'moment-timezone'
import Command from './command'

export default class ScheduleCommnand extends Command {
  constructor (gcal) {
    super('schedule', 'authorize', false)
    this.gcal = gcal
  }

  async getResponse (args, nick) {
    let now = new Date()
    let later = new Date()
    later.setDate(now.getDate() + 1)

    let events = await this.gcal.getEvents(now, later)
    let reply = 'There are no scheduled shows for the next 24 hours'
    events = events.filter(event => {
      return moment(event.start.dateTime).isAfter()
    })
    if (events.length > 0) {
      reply = 'Scheduled Shows for the Next 24 Hours:'
      events.forEach(event => {
        let timeWords = moment().to(event.start.dateTime, true)
        let showDate = moment(event.start.dateTime).tz(moment.tz.guess())
        let timeIsLink = `http://time.is/${showDate.format('HHmm_DD_MMM_YYYY_zz')}`
        reply += `\n${timeWords} - ${event.summary} - ${timeIsLink}`
      })
    }
    return reply
  }
}
