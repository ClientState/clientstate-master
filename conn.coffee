knexion = require('knex')
  client: 'postgres'
  connection:
    host: process.env.PG_PORT_5432_TCP_ADDR or '127.0.0.1'
    # taking advantage of no $USER on container ..
    user: process.env.USER or 'postgres'
    password: process.env.PG_PASSWORD or ''
    database: process.env.PG_DATABASE or 'csm'
    charset: 'utf8'
  #debug: true

global.knexion = knexion
