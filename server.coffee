express = require 'express'
app = express()
oauth = require 'oauth-express'
mod = require './models'

bodyParser = require 'body-parser'
app.use bodyParser.json()
app.use bodyParser.urlencoded extended: true

# oauth-express
app.get '/auth/:provider', oauth.handlers.auth_provider_redirect
app.get '/auth_callback/:provider', oauth.handlers.auth_callback
oauth.emitters.github.on 'complete', require("./oauth-events").github_complete

# static
app.use "/public", express.static "#{__dirname}/public"
app.use "/lib", express.static "#{__dirname}/bower_components"
app.use "/", express.static "#{__dirname}/views"

# Extract User from access_token header
# "access_token: OAUTH-TOKEN"
auth = (req, res, next) ->

  abort = () ->
    res.status(403).write "valid access_token header required"
    res.send()

  if req.headers.access_token is undefined
    abort()

  # TODO: cache access_token - don't hit database
  (new mod.ProviderLoginDetails(
    access_token: req.headers.access_token)
  ).fetch(withRelated: ['user']).then (pld) ->
    if pld is null
      abort()
      return
    user = pld.related 'user'
    if user
      req.user = user
      next()
      return
    else
      abort()
      return

app.use auth


# TODO: handle errors
app.get "/apps", (req, res) ->
  # list all Apps for User
  new mod.App(user_id: req.user.id).fetchAll().then (collection) ->
    res.send collection.toJSON()
    return

app.post "/apps", (req, res) ->
  # create new App for User
  app = new mod.App
    name: req.body.name
    user_id: req.user.id
  app.save().then () ->
    res.send "OK"
    return

# app at ENV -- GITHUB_CLIENT_ID and GITHUB_CLIENT_SECRET
# must match the callback url, in this case,
# http://localhost:4000/auth_callback/github
server = app.listen 4000, () ->
  console.log 'Listening on port %d', server.address().port

module.exports.app = app
