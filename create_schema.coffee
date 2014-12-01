require "./conn"

#   /------*PLD
# User ----*App------*Container

# TODO - is this the way to build the schema? hrm.
m = require "./models"
c = (model) ->
  return knexion.schema.createTableIfNotExists(
    model.tableName,
    model.createTable
  )

l = console.log

c(m.User).then () ->
  l "User created"
  c(m.ProviderLoginDetails).then () ->
    l "ProviderLoginDetails created"
  c(m.App).then () ->
    l "App created"
    c(m.Container).then () ->
      l "Container created"
      process.exit()
