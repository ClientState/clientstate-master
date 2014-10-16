require './conn'
bookshelf = require('bookshelf')(knexion)


User = bookshelf.Model.extend
  #@tableName: 'users'
  tableName: 'users'
  hasTimestamps: true

  logins: () ->
    @hasMany ProviderLoginDetails

User.createTable = (t) ->
    t.increments 'id'
    #t.string 'first_name'
    #t.string 'last_name'
    #t.string 'password'
    t.timestamps()
User.tableName = 'users'

ProviderLoginDetails = bookshelf.Model.extend
  # http://stackoverflow.com/a/19506170/177293
  # hrm .. if I want to use Model.tableName without new ...
  #@tableName: 'provider_login_details'
  # this is the way it wants to be for bookshelf new/forge
  tableName: 'provider_login_details'
  hasTimestamps: true


ProviderLoginDetails.createTable = (t) ->
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
ProviderLoginDetails.tableName = 'provider_login_details'


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
