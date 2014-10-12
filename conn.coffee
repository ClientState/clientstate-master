knex = require('knex')
  client: 'postgres'
  connection:
    host: '127.0.0.1'
    user: process.env.PG_USER
    password: process.env.PG_PASSWORD
    database: 'csm'
    charset: 'utf8'

module.exports.knex = knex
