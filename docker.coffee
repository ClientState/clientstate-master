Docker = require 'dockerode'

docker = new Docker
  # boot2docker is default
  # for now, we have just
  # http://blog.sequenceiq.com/blog/2014/10/17/boot2docker-tls-workaround/
  host: process.env.DOCKER_PARENT_HOST or '192.168.59.103'
  port: process.env.DOCKER_PARENT_PORT or 2375
  # TODO: actually use TLS
  #protocol: 'https'
  #ca: fs.readFileSync('ca.pem'),
  #cert: fs.readFileSync('cert.pem'),
  #key: fs.readFileSync('key.pem')

#docker = new Docker(host: '127.0.0.1', port: 2375)  #, protocol: 'tcp')

docker.print = () -> console.log(arguments)

global.docker = docker
