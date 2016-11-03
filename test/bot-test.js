/* eslint-env mocha */

import chai from 'chai'
let expect = chai.expect

import config from '../src/config/config'

import Bot from '../src/bot.js'

describe('Bot#constructor', () => {
  it('should set config property', () => {
    var bot = new Bot(config)
    expect(bot.config).to.not.be.null
  })
})

describe('Bot#start', () => {
  it('should set client property', () => {
    var bot = new Bot(config)
    bot.start()
    expect(bot.client).to.not.be.null
  })
})
