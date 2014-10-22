global.uuid = require 'node-uuid'
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
  new mod.App(
    user_id: req.user.id
  ).fetchAll(
    withRelated: ['services', 'provider_id_secrets']
  ).then (collection) ->
    res.send collection.toJSON()
    return

app.post "/apps", (req, res) ->
  # create new App for User
  app = new mod.App
    id: uuid.v4()
    name: req.body.name
    user_id: req.user.id
  app.save(null, method: "insert").then () ->
    res.send "OK"
    return

app.get "/apps/:id/services", (req, res) ->
  # return services for id/user_id
  new mod.App(
    id: req.params.id
    user_id: req.user.id
  ).services().fetch().then (services) ->
    res.send services.toJSON()

app.post "/apps/:id/services", (req, res) ->
  # create new Service for App
  # POST JSON with {"name": "redis"}, a address and port will be derived and returned
  # App must be for req.user
  req.body.name = req.body.name or "redis"  # hack to get select default
  new mod.App(id: req.params.id).fetch().then (app_mod) ->
    if app_mod is null
      res.status(404).write("App not found")
      res.send()
      return
    new mod.Service(
      app_id: app_mod.id, name: req.body.name
    ).save(null, method: "insert").then (service) ->
      # TODO - magic, spin up service, get address/port, return to client
      res.send service.toJSON()

app.post "/apps/:id/provider-id-secrets", (req, res) ->
  # Create PIS for App
  PIS =
    app_id: req.params.id
    client_id: req.body.client_id
    client_secret: req.body.client_secret
    oauth_redirect_url: req.body.oauth_redirect_url
  new mod.ProviderIDSecret(PIS).save(null, method: "insert").then (pis) ->
    res.send "Ok"

# app at ENV -- GITHUB_CLIENT_ID and GITHUB_CLIENT_SECRET
# must match the callback url, in this case,
# http://localhost:4000/auth_callback/github
server = app.listen 4000, () ->
  console.log 'Listening on port %d', server.address().port

module.exports.app = app
