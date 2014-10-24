Docker = require 'dockerode'

docker = new Docker
  host: process.env.DOCKERODE_HOST or '127.0.0.1'
  port: process.env.DOCKERODE_PORT or 2375
  #ca: fs.readFileSync('ca.pem'),
  #cert: fs.readFileSync('cert.pem'),
  #key: fs.readFileSync('key.pem')

#docker = new Docker(host: '127.0.0.1', port: 2375)  #, protocol: 'tcp')

docker.print = () -> console.log(arguments)
#console.log docker
module.exports = docker
