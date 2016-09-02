import request from 'request';
import config from '../config/config';

export default {
    getFromConfig(callback) {
        let now = new Date();
        let later = new Date().setDate(now.getDate() + 2);

        let url = `https://www.googleapis.com/calendar/v3/calendars/${config.google.calendarId}/events?key=${config.google.apiKey}&singleEvents=true&orderBy=startTime&timeMin=${now.toISOString()}&timeMax=${later.toISOString()}`;
        request(url, (error, response, body) => {
            if (!error && response.statusCode === 200) {
                if (body === null) {
                    console.error(`Error: ${response}`);
                } else {
                    callback(response.items);
                }
            } else {
                console.error(`Error: ${error}`);
            }
        });
    }
};
