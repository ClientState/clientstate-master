// Generated by CoffeeScript 1.8.0
(function() {
  var Docker, docker;

  Docker = require('dockerode');

  docker = new Docker({
    host: process.env.DOCKERODE_HOST || '127.0.0.1',
    port: process.env.DOCKERODE_PORT || 2375
  });

  docker.print = function() {
    return console.log(arguments);
  };

  module.exports = docker;

}).call(this);
