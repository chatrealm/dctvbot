/* eslint-env mocha */

import chai from 'chai'
let expect = chai.expect

import config from '../src/config/config'

import Bot from '../src/bot.js'

describe('Bot', () => {
  let bot

  beforeEach(() => {
    bot = new Bot(config)
  })

  describe('#constructor', () => {
    it('should set config property', () => {
      expect(bot.config).to.not.be.undefined
    })
  })

  describe('#start', () => {
    it('should set client property', () => {
      bot.start()
      expect(bot.client).to.not.be.undefined
    })
  })
})
