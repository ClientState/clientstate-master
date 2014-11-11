Docker = require 'dockerode'

docker = new Docker
  host: process.env.DOCKER_PARENT_HOST or '172.17.8.101'
  port: process.env.DOCKER_PARENT_PORT or 2375
  #ca: fs.readFileSync('ca.pem'),
  #cert: fs.readFileSync('cert.pem'),
  #key: fs.readFileSync('key.pem')

#docker = new Docker(host: '127.0.0.1', port: 2375)  #, protocol: 'tcp')

docker.print = () -> console.log(arguments)

global.docker = docker
