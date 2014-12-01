request = require 'supertest'
{assert} = require "chai"


app = require('../server').app

models = {
  User
  ProviderLoginDetails
  App
  ProviderIDSecret
} = require "../models"

# global.uuid
# global.docker
require("./global_mocks")()


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
      new ProviderLoginDetails(details).save(null, method: "insert").then (pld) ->
        new App(
          id: "this-uuid"
          name: "meltodies"
          user_id: user.id
        ).save(null, method: "insert").then (app) ->
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
  it 'returns 403 with non-existent access_token', (done) ->
    request(app)
      .get('/apps')
      .set(access_token: "nonExiStent")
      .expect(403, done)


describe 'Create new App for User', () ->
  beforeEach createAppForUser

  it 'creates App through REST', (done) ->
    request(app)
      .post('/apps')
      .set(access_token: "qwerty")
      .set("Content-Type": "application/json;charset=UTF-8")
      .send('
{
  "name":"Frilz-not-kidding",
  "id":"theid",
  "secret":"thesecret",
  "oauth_redirect_url":"http://foobar.com"
}')
      .expect(200)
      .end (err, res) ->
        new App(user_id: 1).fetchAll().then (apps) ->
          assert.equal apps.length, 2
          assert.equal(apps._byId['theid'].get('name'), "Frilz-not-kidding")
          done()


describe 'Services for App', () ->
  beforeEach createAppForUser

  it 'Create Service for App', (done) ->
    request(app)
      .post('/apps/this-uuid/launch')
      .set(access_token: "qwerty")
      .set("Content-Type": "application/json;charset=UTF-8")
      .send('')
      .expect(200)
      .end (err, res) ->
        new App(id: "this-uuid").containers().fetch().then (collection) ->
          assert.equal collection.models.length, 2
          assert.equal docker.callCounts.createContainer, 2
          done()

