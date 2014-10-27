require "./conn"

###
created = 0

for name, Model of require "./models"

  f = () ->
    console.log "created table for #{name}"
    created += 1
    s = knexion.schema.createTableIfNotExists(
      Model.tableName, Model.createTable
    ).then (a, b, c) ->
      created -= 1
      console.log created
      if created is 0
        process.exit()
    .catch (err) ->
      console.log 'err!', created
      console.log arguments
###

#   /------*PLD
# User ----*App------*Service----------*Container
#             \------*PIS


# TODO - is this the way to build the schema? hrm.
m = require "./models"
c = (model) ->
  return knexion.schema.createTableIfNotExists(model.tableName, model.createTable)

l = console.log

c(m.User).then () ->
  l "User created"
  c(m.ProviderLoginDetails).then () ->
    l "ProviderLoginDetails created"
  c(m.App).then () ->
    l "App created"
    c(m.ProviderIDSecret).then () ->
      l "ProviderIDSecret created"
    c(m.Service).then () ->
      l "Service created"
      c(m.Container).then () ->
        l "Container created"
        process.exit()
