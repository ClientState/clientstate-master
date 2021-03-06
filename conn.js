// Generated by CoffeeScript 1.8.0
(function() {
  var knexion;

  knexion = require('knex')({
    client: 'postgres',
    connection: {
      host: process.env.PG_PORT_5432_TCP_ADDR || '127.0.0.1',
      user: process.env.USER || 'postgres',
      password: process.env.PG_PASSWORD || '',
      database: process.env.PG_DATABASE || 'csm',
      charset: 'utf8'
    }
  });

  global.knexion = knexion;

}).call(this);
