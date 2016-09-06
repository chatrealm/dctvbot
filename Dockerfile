FROM mhart/alpine-node

WORKDIR /dctvbot
COPY package.json package.json
COPY bin bin
RUN npm install --production

CMD node bin/dctvbot.js