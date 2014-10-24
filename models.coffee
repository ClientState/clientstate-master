require './conn'
bookshelf = require('bookshelf')(knexion)

docker = require './docker'


class User extends bookshelf.Model
  tableName: 'users'
  hasTimestamps: true

  logins: () ->
    this.hasMany ProviderLoginDetails

  # DDL with knex
  @tableName = 'users'
  @createTable = (t) ->
    t.increments 'id'
    t.timestamps()
    return


class ProviderLoginDetails extends bookshelf.Model
  tableName: 'provider_login_details'
  hasTimestamps: true

  user: () ->
    @belongsTo User

  @tableName = 'provider_login_details'
  @createTable: (t) ->
    t.string('id').primary()
    t.string 'provider'
    t.string('access_token').index().unique()
    t.text 'data'
    t.timestamps()
    t.integer('user_id')
      .unsigned()
      .references('id')
      .inTable('users')
    return
      # .onDelete
      # .onUpdate


class App extends bookshelf.Model
  tableName: 'apps'
  hasTimestamps: true

  user: () ->
    @belongsTo User

  services: () ->
    @hasMany Service

  provider_id_secrets: () ->
    @hasMany ProviderIDSecret

  create_new_service: (opts, cb) =>
    # opts is object that comes in req.body as JSON
    if (opts.type is "redis") or (opts.type is undefined)
      @_create_redis opts, cb

  _create_redis: (opts, cb) =>
    console.log opts
    self = this
    new Service(
      app_id: @id
      type: opts.type
    ).save(null, method: "insert").then (service) ->
      ###
      # Assume that we have an images named
      #     skyl/clientstate-redis
      #     redis images
      # can build from the submodule - docker/clientstate-redis
      # Assume we have a docker client instantiated with Env variables
      #
      # Run redis and link to skyl/clientstate-redis
      #
      # https://docs.docker.com/reference/api/docker_remote_api_v1.15/#create-a-container
      # https://docs.docker.com/reference/api/docker_remote_api_v1.15/#start-a-container
      ###

      redis_create_options = {
        "Image": "redis",
        "ExposedPorts": {
          "6379/tcp": {}
        },
      }
      docker.createContainer redis_create_options, (err, redisContainer) ->
        #console.log "@@@@@@@@@@@@@@ createContainer redis", arguments

        redis_start_options = {
          "PortBindings": { "6379/tcp": {} },
          "PublishAllPorts": true,
        }
        redisContainer.start redis_start_options, (err, data) ->
          #console.log "redis start>>>>>>>>>>>>>>>>>>>>>>>>", arguments

          # TODO: support more than github
          for pis_mod in self.relations.provider_id_secrets.models
            #console.log "********"
            #console.log pis_mod
            #console.log pis_mod.get "provider"
            #console.log "********"

            if pis_mod.get('provider') is "github"
              GITHUB_CLIENT_ID = pis_mod.get 'client_id'
              GITHUB_CLIENT_SECRET = pis_mod.get 'client_secret'
              OAUTH_REDIRECT_URL = pis_mod.get 'oauth_redirect_url'
              #console.log GITHUB_CLIENT_SECRET, GITHUB_CLIENT_ID, OAUTH_REDIRECT_URL
              break

          redisContainer.inspect (err, rcInfo) ->
            #console.log rcInfo.Name
            cs_create_options = {
              "Image": "skyl/clientstate-redis"
              "ExposedPorts": {
                "3000/tcp": {}
              }
              Env: [
                "GITHUB_CLIENT_ID=#{GITHUB_CLIENT_ID}"
                "GITHUB_CLIENT_SECRET=#{GITHUB_CLIENT_SECRET}"
                "OAUTH_REDIRECT_URL=#{OAUTH_REDIRECT_URL}"
                "DEBUG=yes"
              ]
            }
            #console.log cs_create_options.Env
            docker.createContainer cs_create_options, (err, csContainer) ->
              #console.log "$$$$$$$$$$$ createContainer clientstate-redis", arguments

              # add port information to service
              cs_start_options = {
                "Links": ["#{rcInfo.Name}:redis"],
                "PortBindings": {"3000/tcp": {}},
                "PublishAllPorts": true,
              }
              csContainer.start cs_start_options, (err, data) ->
                #console.log "cs.start>>>>>>>>>>>>>>>>>>>>>>>>>>>>>", arguments

                cb service
                return


  @tableName = 'apps'
  @createTable = (t) ->
    t.string('id').primary()
    t.timestamps()
    t.string 'name'
    t.integer('user_id')
      .unsigned()
      .references('id')
      .inTable('users')
    return


class ProviderIDSecret extends bookshelf.Model
  tableName: 'provider_id_secrets'
  hasTimestamps: true

  app: () ->
    @belongsTo App

  @tableName = 'provider_id_secrets'
  @createTable = (t) ->
    t.increments 'id'
    t.timestamps()
    t.string 'provider'
    t.string 'client_id'
    t.string 'client_secret'
    t.string 'oauth_redirect_url'
    t.string('app_id')
      .references('id')
      .inTable('apps')
    return


class Service extends bookshelf.Model
  tableName: 'services'
  hasTimestamps: true

  app: () ->
    @belongsTo App





  @tableName = 'services'
  @createTable = (t) ->
    t.increments 'id'
    t.timestamps()
    t.string 'type'  # redis, postgres

    # TODO: divide out into objects?
    # images, containers, locations to load balancers?
    # for now, just launch 1 container ...
    # already, there are two containers for the 1 service
    # - redis linked to clientstate-redis node app.
    t.string 'name'
    t.string 'address'
    t.string 'port'

    t.string('app_id')
      .references('id')
      .inTable('apps')
    return


global.bookshelf = bookshelf
module.exports.User = User
module.exports.ProviderLoginDetails = ProviderLoginDetails
module.exports.App = App
module.exports.ProviderIDSecret = ProviderIDSecret
module.exports.Service = Service
