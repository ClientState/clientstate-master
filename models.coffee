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
    t.string 'client_id'
    t.string 'client_secret'
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
