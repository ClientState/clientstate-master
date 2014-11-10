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


app.get "/services/:id", (req, res) ->
  # translate a service id into a backend information
  # this is for nginx to know where to proxy to
  new mod.Service(id: req.params.id).fetch(
    withRelated: ['containers']
  ).then (service) ->
    # store something on service to let us know what to return here
    res.send service.port_json


# Extract User from access_token header
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
    abort()

app.use "/apps", auth

app.get "/apps", (req, res) ->
  # list all Apps for User
  new mod.App(
    user_id: req.user.id
  ).fetchAll(
    withRelated: ['services', 'services.containers', 'provider_id_secrets']
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

app.put "/apps/:id", (req, res) ->
  new mod.App(
    id: req.params.id
    user_id: req.user.id
  ).save({name: req.body.name}, {method: "update"}).then (app) ->
    res.send "OK"
    return

app.post "/apps/:id/provider-id-secrets", (req, res) ->
  # Create PIS for App
  PIS =
    provider: "github"
    app_id: req.params.id
    client_id: req.body.client_id
    client_secret: req.body.client_secret
    oauth_redirect_url: req.body.oauth_redirect_url
  new mod.ProviderIDSecret(PIS).save(null, method: "insert").then (pis) ->
    res.send "OK"

app.get "/apps/:id/services", (req, res) ->
  # return services for id/user_id
  new mod.App(
    id: req.params.id
    user_id: req.user.id
  ).services(
    withRelated: ['containers']
  ).fetch().then (services) ->
    res.send services.toJSON()

app.post "/apps/:id/services", (req, res) ->
  # create new Service for App
  # POST JSON with {"name": "redis"}
  # App must be for req.user
  new mod.App(
    id: req.params.id
    user_id: req.user.id
  ).fetch(
    withRelated: ['provider_id_secrets']
  ).then (app_mod) ->
    if app_mod is null
      res.status(404).write("App not found")
      res.send()
      return
    app_mod.create_new_service req.body, (service) ->
      res.send service.toJSON()
      return

app.delete "/apps/:app_id/services/:service_id", (req, res) ->
  new mod.App(
    id: req.params.app_id
    user_id: req.user.id
  ).fetch(
    withRelated: ['services']
  ).then (app_mod) ->
    if app_mod is null
      res.status(404).write("App not found")
      res.send()
      return
    service = app_mod.related('services')._byId[req.params.service_id]
    service.delete () ->
      res.send 'OK'


# app at ENV -- GITHUB_CLIENT_ID and GITHUB_CLIENT_SECRET
# must match the callback url, in this case,
# http://localhost:4000/auth_callback/github
server = app.listen 4000, () ->
  console.log 'Listening on port %d', server.address().port
  # console.log process.env

module.exports.app = app
