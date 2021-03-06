models = {
  User
  ProviderIDSecret
  ProviderLoginDetails
  App
  Container
} = require "../models"

{assert, expect} = require "chai"

# global.uuid
# global.docker
require("./global_mocks")()


beforeEach (done) ->
  docker.reset()
  # http://stackoverflow.com/a/18060545/177293
  knexion.raw(
    "TRUNCATE TABLE #{(v.tableName for k,v of models).join(',')} RESTART IDENTITY"
  ).then () ->
    done()


describe 'User model tests', () ->
  it 'autoincrements id, insert and fetchAll work', (done) ->
    user = new User()
    user.save(null, method: "insert").then (model) ->
      assert model.id is 1
      (new User()).save(null, method: "insert").then (m2) ->
        assert m2.id is 2
        User.fetchAll().then (res) ->
          assert res.models.length is 2
          done()


describe 'Truncate worked', () ->
  it 'has no Users', (done) ->
    User.fetchAll().then (res) ->
      assert res.models.length is 0
      done()


describe 'Transaction', () ->
  it 'rolls back on error', (done) ->
    tx = bookshelf.transaction (t) ->
      (new User).save(null, method: "insert", transacting: t).then (m1) ->
        (new User).save(
          {oops: "nope"}, {method: "insert", transacting: t}
        ).then () ->
    tx.catch (err) ->
      User.fetchAll().then (res) ->
        assert res.models.length is 0
        done()

  it 'succeeds when no error', (done) ->
    tx = bookshelf.transaction (t) ->
      (new User).save(null, method: "insert", transacting: t).then (m1) ->
        (new User).save(null, method: "insert", transacting: t).then (m2) ->
    tx.then () ->
      User.fetchAll().then (res) ->
        assert res.models.length is 2
        done()


describe 'User has many ProviderLoginDetails', () ->

  it 'User.logins returns ProviderLoginDetails', (done) ->
    # save a new User
    (new User).save().then (user) ->
      # create a PLD for the user
      pld = new ProviderLoginDetails
        id: "razzafrazza"
        provider: "github"
        data: '{"some": "thing"}'
        user_id: user.id
      pld.save(null, method: "insert").then (new_pld) ->
        # fetch the related user
        new_pld.user().fetch().then (reluser) ->
          assert reluser.get('id') is user.id is 1

          # fetch the logins for this user
          reluser.logins().fetch().then (plds) ->
            assert plds.models[0].get('id') is 'razzafrazza'
            done()


describe 'Collections', () ->

  beforeEach (done) ->
    (new User).save().then (user) ->
      done()

  it 'fetching User.collection gives back user', (done) ->
    User.collection().fetch().then (collection) ->
      assert collection.models[0].id is 1
      done()


describe 'Launch Redis Service', () ->

  beforeEach (done) ->
    new App(
      id: "theid"
      secret: "thesecret"
      oauth_redirect_url: "theurl"
    ).save(null, method: "insert").then (app) ->
      done()

  it 'calls docker correctly when app.launch_service', (done) ->
    new App(id: "theid").fetch().then (app) ->
      opts = {}
      app.launch_service opts, () ->
        assert.equal docker.callCounts.createContainer, 2
        env = docker.arguments.createContainer[1]['0'].Env
        expect(env).to.include('GITHUB_CLIENT_ID=theid')
        expect(env).to.include('GITHUB_CLIENT_SECRET=thesecret')
        expect(env).to.include('OAUTH_REDIRECT_URL=theurl')
        done()

describe 'Relaunch Redis Service', () ->
  beforeEach (done) ->
    new App(
      id: "theid"
      secret: "thesecret"
      oauth_redirect_url: "theurl"
    ).save(null, method: "insert").then (app) ->
      new Container(
        app_id: "theid"
        id: "foobar1"
      ).save(null, method: "insert").then () ->
        done()

  it 'makes correct calls when app.relaunch_service', (done) ->
    new App(id: "theid").fetch().then (app) ->
      opts = {}
      app.containers().fetch().then (collection) ->
        assert.equal(collection.models.length, 1)
        assert.equal(collection.models[0].id, "foobar1")

        app.relaunch_service opts, () ->
          app.containers().fetch().then (collection) ->
            assert.equal(collection.models.length, 2)
            # foobar1 is not here, trust me
            #console.log collection.models
            assert.equal docker.callCounts.createContainer, 2
            env = docker.arguments.createContainer[1]['0'].Env
            expect(env).to.include('GITHUB_CLIENT_ID=theid')
            expect(env).to.include('GITHUB_CLIENT_SECRET=thesecret')
            expect(env).to.include('OAUTH_REDIRECT_URL=theurl')
            done()
