express = require 'express'
app = express()
oauth = require 'oauth-express'

{User} = require "./models"

# oauth-express
app.get '/auth/:provider', oauth.handlers.auth_provider_redirect
app.get '/auth_callback/:provider', oauth.handlers.auth_callback
oauth.emitters.github.on 'complete', (result) ->
  console.log '**************************************'
  console.log result
  console.log()
  console.log()
  console.log()
  console.log()


app.use "/public", express.static "#{__dirname}/public"
app.use "/lib", express.static "#{__dirname}/bower_components"
app.use "/", express.static "#{__dirname}/views"

# app at ENV -- GITHUB_CLIENT_ID and GITHUB_CLIENT_SECRET
# must match the callback url, in this case,
# http://localhost:4000/auth_callback/github
server = app.listen 4000, () ->
    console.log 'Listening on port %d', server.address().port

module.exports.app = app
