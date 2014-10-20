request = require 'supertest'
app = require('../server').app

models = {
  User
  ProviderLoginDetails
  App
} = require "../models"

{assert} = require "chai"


createAppForUser = (done) ->
  knexion.raw(
    "TRUNCATE TABLE #{(v.tableName for k,v of models).join(',')} RESTART IDENTITY"
  ).then () ->
    (new User).save().then (user) ->
      details =
        id: "61438"
        provider: "github"
        access_token: "qwerty"
        data: {}
        user_id: user.get 'id'
      (new ProviderLoginDetails(details)).save(null, method: "insert").then (pld) ->
        (new App(name: "meltodies", user_id: user.id)).save().then (app) ->
          done()


describe 'Get Apps for User', () ->
  beforeEach createAppForUser

  it 'returns the Apps for user as JSON', (done) ->
    request(app)
      .get('/apps')
      .set({"access_token": "qwerty"})
      .expect(200)
      .end (err, res) ->
        assert res.body[0].name is "meltodies"
        done()
  it 'returns 403 with no access_token', (done) ->
    request(app)
      .get('/apps')
      .expect(403, done)
