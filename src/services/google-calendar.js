import request from 'request';
import config from '../config/config';

export default {
    getFromConfig(callback) {
        let now = new Date();
        let later = new Date();
        later.setDate(now.getDate() + 1);

        let url = 'https://www.googleapis.com/calendar/v3/calendars' +
            `/${config.google.calendarId}/events?key=${config.google.apiKey}` +
            `&timeMin=${now.toISOString()}&timeMax=${later.toISOString()}` +
            `&singleEvents=true&orderBy=startTime`;
        request(url, (error, response, body) => {
            if (!error && response.statusCode === 200) {
                if (body === null) {
                    console.error(`Error: ${response}`);
                } else {
                    callback(JSON.parse(body).items);
                }
            } else {
                console.error(`Error: ${error}`);
            }
        });
    }
};
