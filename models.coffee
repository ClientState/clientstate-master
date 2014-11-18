# global.knexion
require './conn'
# global.redis_client
require './redis_conf'
# global.docker
require './docker'
bookshelf = require('bookshelf')(knexion)


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
    t.json 'data'
    t.timestamps()
    t.integer('user_id')
      .unsigned()
      .references('id')
      .inTable('users')
      # .onDelete
      # .onUpdate
    return


class App extends bookshelf.Model
  tableName: 'apps'
  hasTimestamps: true

  user: () ->
    @belongsTo User

  containers: () ->
    @hasMany Container

  provider_id_secrets: () ->
    @hasMany ProviderIDSecret

  # opts are now theoretical
  # req.body is passed straight in
  launch_service: (opts, cb) =>
    self = this
    ###
    # Assume that we have an images named
    #     skyl/clientstate-redis
    #     redis images
    # can build from the submodule - docker/clientstate-redis
    # Assume we have a docker client instantiated with Env variables
    #
    # Run redis and link to skyl/clientstate-redis
    #
    # https://docs.docker.com/reference/api/docker_remote_api_v1.15/
    ###

    redis_create_options = {
      "Image": "redis",
      "ExposedPorts": {
        "6379/tcp": {}
      },
    }
    docker.createContainer redis_create_options, (err, redisContainer) ->

      redis_start_options = {
        "PortBindings": { "6379/tcp": {} },
        #"PublishAllPorts": true,
      }
      redisContainer.start redis_start_options, (err, data) ->

        # TODO: support more than github
        for pis_mod in self.relations.provider_id_secrets.models
          if pis_mod.get('provider') is "github"
            GITHUB_CLIENT_ID = pis_mod.get 'client_id'
            GITHUB_CLIENT_SECRET = pis_mod.get 'client_secret'
            OAUTH_REDIRECT_URL = pis_mod.get 'oauth_redirect_url'
            break

        redisContainer.inspect (err, rcInfo) ->
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
          docker.createContainer cs_create_options, (err, csContainer) ->

            # add port information to service
            cs_start_options = {
              "Links": ["#{rcInfo.Name}:redis"],
              "PortBindings": {"3000/tcp": {}},
              #"PublishAllPorts": true,
            }
            csContainer.start cs_start_options, (err, data) ->
              csContainer.inspect (err, cscInfo) ->
                redis_client.set(
                  self.id,
                  "#{cscInfo.NetworkSettings.IPAddress}:3000"
                )
                # write to the DB the details of the 2 containers
                self.save_containers cscInfo, rcInfo, () ->
                  cb self
                  return

  save_containers: () =>
    # pass in a list of infos that come in from docker inspect

    # TODO
    # https://developer.mozilla.org/en-US/docs
    # /Web/JavaScript/Reference/Functions/arguments
    # You should not slice on arguments
    # because it prevents optimizations in JavaScript engines (V8 for example).
    args = Array.prototype.slice.call arguments
    cb = args[arguments.length - 1]

    containers_left = args.length - 1
    for container in args.slice(0, -1)
      new Container(
        id: container.Id
        app_id: @id
        inspect_info: container
      ).save(null, method: "insert").then () ->

        containers_left -= 1
        if containers_left is 0
          cb()
          return

  delete: (cb) =>
    self = @
    @containers().fetch().then (collection) ->
      for container in collection.models
        dc = docker.getContainer(container.id)
        dc.stop () ->
          dc.remove () ->
      self.destroy().then cb

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
      .onDelete('CASCADE')
    return


class Container extends bookshelf.Model
  tableName: 'containers'
  hasTimestamps: true

  app: () ->
    @belongsTo App

  @tableName = 'containers'
  @createTable = (t) ->
    t.string('id').primary()
    t.timestamps()
    t.json 'inspect_info'
    t.string('app_id')
      .references('id')
      .inTable('apps')
      .onDelete('CASCADE')
    return


global.bookshelf = bookshelf
module.exports.User = User
module.exports.ProviderLoginDetails = ProviderLoginDetails
module.exports.App = App
module.exports.ProviderIDSecret = ProviderIDSecret
module.exports.Container = Container
