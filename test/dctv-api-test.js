/* eslint-env mocha */

import chai from 'chai'
let expect = chai.expect

import config from '../src/config/config'

import DctvApi from '../src/dctv-api'



describe('DctvApi', () => {
  let dctvApi

  beforeEach(() => {
    dctvApi = new DctvApi()
  })

  describe('#constructor', () => {
    it('should set config property', () => {
      expect(dctvApi.config).to.not.be.undefined
    })
  })
})
