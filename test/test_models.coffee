models = {
  User
  ProviderLoginDetails
} = require "../models"

{assert} = require "chai"


beforeEach (done) ->
  # http://stackoverflow.com/a/18060545/177293
  knexion.raw(
    "TRUNCATE TABLE #{(v.tableName for k,v of models).join(',')} RESTART IDENTITY"
  ).then done()


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



