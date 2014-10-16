express = require 'express'
app = express()
oauth = require 'oauth-express'

# global.bookshelf, for now
{
  User
  ProviderLoginDetails
} = require "./models"

# oauth-express
app.get '/auth/:provider', oauth.handlers.auth_provider_redirect
app.get '/auth_callback/:provider', oauth.handlers.auth_callback
oauth.emitters.github.on 'complete', (result) ->

  trans = bookshelf.transaction (t) ->
    uid = result.user_data.id

    model =
      id: uid
      provider: "github"
      data: result.user_data

    pld = new ProviderLoginDetails(model).fetch(null, transaction: t).then (m) ->
      if m is null
        # new ProviderLoginDetails
        # are we logged in as someone else?
        # TODO: add github to user who is logged in with $OTHER_OAUTH
        # instead of just assuming that we create a new user
        user = new User()
        user.save(null, method: "insert", transacting: t).then (user) ->
          model.user_id = user.id
          pld = new ProviderLoginDetails model
          pld.save(null, {method: "insert", transacting: t}).then () ->
            console.log "OK!"
            return
      else
        console.log "!!!!!! ALREADY HAVE", m.id
        return

  trans.catch (err) ->
    console.log "ERR", err


app.use "/public", express.static "#{__dirname}/public"
app.use "/lib", express.static "#{__dirname}/bower_components"
app.use "/", express.static "#{__dirname}/views"

# app at ENV -- GITHUB_CLIENT_ID and GITHUB_CLIENT_SECRET
# must match the callback url, in this case,
# http://localhost:4000/auth_callback/github
server = app.listen 4000, () ->
    console.log 'Listening on port %d', server.address().port

module.exports.app = app
