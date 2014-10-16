knexion = require('knex')
  client: 'postgres'
  connection:
    host: '127.0.0.1'
    user: process.env.PG_USER
    password: process.env.PG_PASSWORD
    database: process.env.PG_DATABASE or "csm"
    charset: 'utf8'
  #debug: true

global.knexion = knexion
