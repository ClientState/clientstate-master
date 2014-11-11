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
      .send('{"name":"Frilz-not-kidding"}')
      .expect(200)
      .end (err, res) ->
        new App(user_id: 1).fetchAll().then (apps) ->
          assert.equal apps.length, 2
          assert.equal(apps._byId['other-uuid'].get('name'), "Frilz-not-kidding")
          done()


describe 'Services for App', () ->
  beforeEach createAppForUser
  it 'empty list of Services for App', (done) ->
    request(app)
      .get('/apps/1/services')
      .set(access_token: "qwerty")
      .expect(200)
      .expect('[]', done)

  it '404 for bad id', (done) ->
    request(app)
      .post('/apps/this-id-is-nogood/services')
      .set(access_token: "qwerty")
      .set("Content-Type": "application/json;charset=UTF-8")
      .send('{"name": "redis"}')
      .expect(404)
      .end (err, res) ->
        new App(id: 'this-id-is-nogood').services().fetch().then (services) ->
          assert.equal services.length, 0
          done()

  it 'Create Service for App', (done) ->
    request(app)
      .post('/apps/this-uuid/services')
      .set(access_token: "qwerty")
      .set("Content-Type": "application/json;charset=UTF-8")
      # type sent in here is important
      .send('{"type": "clientstate-redis"}')
      .expect(200)
      .end (err, res) ->
        new App(id: "this-uuid").services().fetch().then (services) ->
          assert.equal services.models[0].get('type'), 'clientstate-redis'
          assert.equal docker.callCounts.createContainer, 2
          done()


describe 'ProviderIDSecrets for App', () ->
  beforeEach createAppForUser

  it 'Create ProviderIDSecret with POST', (done) ->
    j =
      client_id: "client_id_asdf"
      client_secret: "client_secret_asdf"
      oauth_redirect_url: "http://example.com/auth/github"
    request(app)
      .post('/apps/this-uuid/provider-id-secrets')
      .set(access_token: "qwerty")
      .set("Content-Type": "application/json;charset=UTF-8")
      .send(JSON.stringify j)
      .expect(200)
      .end (err, res) ->
        new ProviderIDSecret(id: 1).fetch().then (pis) ->
          assert.equal pis.get("app_id"), "this-uuid"
          assert.equal pis.get("client_id"), j.client_id
          assert.equal pis.get("client_secret"), j.client_secret
          assert.equal pis.get("oauth_redirect_url"), j.oauth_redirect_url
          done()






