import request from 'request'

export default class GoogleCalendar {
  constructor (calendarId, apiKey) {
    this.calendarId = calendarId
    this.apiKey = apiKey
  }

  getEvents (startTime, endTime) {
    let url = 'https://www.googleapis.com/calendar/v3/calendars/'
    url += `${this.calendarId}/events/`
    url += `?key=${this.apiKey}`
    url += `&timeMin=${startTime.toISOString()}`
    url += `&timeMax=${endTime.toISOString()}`
    url += '&singleEvents=true'
    url += '&orderBy=startTime'

    return new Promise((resolve, reject) => {
      request(url, (error, response, body) => {
        if (error) {
          reject(error)
          return
        }
        resolve(JSON.parse(body).items)
      })
    })
  }
}
