global.uuid = require 'node-uuid'
express = require 'express'
app = express()
oauth = require 'oauth-express'
# global.redis_client
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

# map appid to backend
# this should be done in nginx/lua directly
app.get "/backends/:id", (req, res) ->
  redis_client.get req.params.id, (err, redis_result) ->
    res.send redis_result


# Extract User from access_token header
# `access_token` is not a standard header name, but I like it.
# "access_token: OAUTH-TOKEN"
auth = (req, res, next) ->

  abort = () ->
    res.status(403).write "valid access_token header required"
    res.send()

  #console.log req.headers.access_token
  if req.headers.access_token is undefined
    #console.log "undefined access_token"
    abort()

  # TODO: cache access_token - don't hit database
  new mod.ProviderLoginDetails(
    access_token: req.headers.access_token
  ).fetch(withRelated: ['user']).then (pld) ->
    if pld is null
      abort()
      return
    user = pld.related 'user'
    if user
      req.user = user
      next()
      return
    abort()

app.use "/apps", auth

app.get "/apps", (req, res) ->
  # list all Apps for User
  new mod.App(
    user_id: req.user.id
  ).fetchAll(
    withRelated: ['containers']
  ).then (collection) ->
    res.send collection.toJSON()
    return

app.post "/apps", (req, res) ->
  # create new App for User
  # Github credentials are posted
  app = new mod.App
    id: req.body.id
    secret: req.body.secret
    name: req.body.name
    oauth_redirect_url: req.body.oauth_redirect_url
    user_id: req.user.id
  app.save(null, method: "insert").then () ->
    res.send "OK"
    return

app.put "/apps/:id", (req, res) ->
  new mod.App(
    id: req.params.id
    user_id: req.user.id
  ).save({name: req.body.name}, {method: "update"}).then (app) ->
    res.send "OK"
    return

app.post "/apps/:id/launch", (req, res) ->
  # create containers for App
  new mod.App(
    id: req.params.id
    user_id: req.user.id
  ).fetch().then (app_mod) ->
    if app_mod is null
      res.status(404).write("App not found")
      res.send()
      return
    # req.body could have options
    app_mod.launch_service req.body, (app) ->
      res.send app.toJSON()
      return

app.post "/apps/:id/relaunch", (req, res) ->
  # create containers for App
  new mod.App(
    id: req.params.id
    user_id: req.user.id
  ).fetch().then (app_mod) ->
    if app_mod is null
      res.status(404).write("App not found")
      res.send()
      return
    # req.body could have options
    app_mod.relaunch_service req.body, (app) ->
      res.send app.toJSON()
      return


# app at ENV -- GITHUB_CLIENT_ID and GITHUB_CLIENT_SECRET
# must match the callback url, in this case,
# http://localhost:4000/auth_callback/github
server = app.listen 4000, () ->
  console.log 'Listening on port %d', server.address().port
  #console.log process.env

module.exports.app = app
