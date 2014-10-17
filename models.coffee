require './conn'
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


class ProviderLoginDetails extends bookshelf.Model
  tableName: 'provider_login_details'
  hasTimestamps: true

  user: () ->
    this.belongsTo User

  @tableName = 'provider_login_details'
  @createTable = (t) ->
    t.string('id').primary()
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

ProviderLoginDetails = bookshelf.Model.extend
  tableName: 'provider_login_details'

  createTable: (t) ->
    #t.increments 'id'
    # Provider unique id
    t.string('id').primary()
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

global.bookshelf = bookshelf
module.exports.User = User
module.exports.ProviderLoginDetails = ProviderLoginDetails
