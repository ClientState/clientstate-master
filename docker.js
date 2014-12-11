// Generated by CoffeeScript 1.8.0
(function() {
  var Docker, docker;

  Docker = require('dockerode');

  docker = new Docker({
    host: process.env.DOCKER_PARENT_HOST || '192.168.59.103',
    port: process.env.DOCKER_PARENT_PORT || 2375
  });

  docker.print = function() {
    return console.log(arguments);
  };

  global.docker = docker;

}).call(this);
