Docker = require 'dockerode'

docker = new Docker
  # TODO: don't hardcode 4444 in here; hrm.
  host: process.env.DOCKER_PORT_4444_TCP_ADDR or '127.0.0.1'
  port: process.env.DOCKER_PORT_4444_TCP_PORT or 2375
  #ca: fs.readFileSync('ca.pem'),
  #cert: fs.readFileSync('cert.pem'),
  #key: fs.readFileSync('key.pem')

#docker = new Docker(host: '127.0.0.1', port: 2375)  #, protocol: 'tcp')

docker.print = () -> console.log(arguments)
#console.log docker
global.docker = docker
