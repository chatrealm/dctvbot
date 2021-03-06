import DCTVApi from './services/dctv-api'
import GoogleCalendar from './services/google-calendar'
import DCTVBot from './dctvbot'

import config from './config/config'

let dctvApi = new DCTVApi(config.dctvApiSecsPro)
let gcal = new GoogleCalendar(config.google.calendarId, config.google.apiKey)
let dctvbot = new DCTVBot(config.channels, config.password, dctvApi, gcal, config.machineLearning)

dctvbot.start()

process.on('unhandledRejection', (reason, p) => {
  console.log('Unhandled Rejection at:', p, 'reason:', reason);
});
