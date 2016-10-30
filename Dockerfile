FROM node:argon

# Create app directory
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# Install app dependencies
COPY package.json /usr/src/app/
COPY yarn.lock /usr/src/app/
RUN npm install -g yarn
RUN yarn

# Bundle app source
COPY . /usr/src/app
RUN yarn run build

CMD node bin/dctvbot.js