require "./conn"

for name, Model of require "./models"
  console.log "create table for", name
  s = knexion.schema.createTableIfNotExists(
    Model.tableName, Model.createTable
  ).then (a, b, c) ->
  s.yield()

# TODO - what's a better way to exit after everything is done?
setTimeout process.exit, 100

