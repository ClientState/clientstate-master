require "./conn"

created = 0

for name, Model of require "./models"
  created += 1
  s = knexion.schema.createTableIfNotExists(
    Model.tableName, Model.createTable
  ).then (a, b, c) ->
    created -= 1
    if created is 0
      process.exit()
