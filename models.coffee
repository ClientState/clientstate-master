{knex} = require './conn'
bookshelf = require('bookshelf')(knex)


class User extends bookshelf.Model
  @tableName: 'users'

  @logins: () ->
    @hasMany ProviderLoginDetails

  @createTable: (t) ->
    t.increments 'id'
    #t.string 'first_name'
    #t.string 'last_name'
    #t.string 'password'
    t.timestamps()


class ProviderLoginDetails extends bookshelf.Model
  @tableName: 'provider_login_details'

  @createTable: (t) ->
    t.increments 'id'
    t.string 'provider'
    t.text 'data'
    t.timestamps()
    t.integer('user_id')
      .unsigned()
      .references('id')
      .inTable('users')
      # .onDelete
      # .onUpdate


###
class App extends bookshelf.Model
  tableName: 'apps'

  # many ProviderIDSecrets

  user: () ->
    @belongsTo User

  services: () ->
    @hasMany Service


class ProviderIDSecret extends bookshelf.Model
  tableName: 'provider_id_secrets'

  # provider
  # client_id
  # client_secret

  app: () ->
    @belongsTo App


class Service extends bookshelf.Model
  tableName: 'services'

  secrets: () ->
    @hasMany ProviderIDSecret

  deployments: () ->
    @hasMany ServiceDeployment


class ServiceDeployment extends bookshelf.Model
  tableName: 'service_deployments'

  service: () ->
    @hasOne Service
###


module.exports.User = User
module.exports.ProviderLoginDetails = ProviderLoginDetails
