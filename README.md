ClientState
===========

Login with $provider, input your secrets, get slick JS APIs to databases.

This is the hub that launches your containers and keeps track of your secrets.




Hack
----

Install Docker. https://docs.docker.com/installation/

Install Fig. http://www.fig.sh/install.html

Clone the repo:

    git clone https://github.com/ClientState/clientstate-master 


Generate a self-signed certificate:

    cd clientstate-master/docker/nginx/certs
    # see http://www.akadia.com/services/ssh_test_certificate.html 
    openssl genrsa -des3 -out server.key 1024
    openssl req -new -key server.key -out server.csr
    # remove passphrase
    cp server.key server.key.org
    openssl rsa -in server.key.org -out server.key
    # self-sign
    openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt

Git the submodule(s):

    git submodule init
    git submodule update
    cd docker/clientstate-redis
    docker build -t skyl/clientstate-redis .

Use docker without sudo -
http://askubuntu.com/questions/477551/how-can-i-use-docker-without-sudo




Create an app on github whose auth callback url is
`https://clientstate.local/auth_callback/github`
(https://github.com/settings/applications)


Add the environment variables:

    export GITHUB_CLIENT_ID="e2fbb3800f01adb8160"
    export GITHUB_CLIENT_SECRET="94d4d2eb9194f90ed4dfac6ad822316262e90c2"    
    export OAUTH_REDIRECT_URL="https://clientstate.local"

Point clientstate.local to your docker host add a line to /etc/hosts:

    # if docker is running on the same host
    0.0.0.0        clientstate.local
    # if docker is running in a virtualbox, maybe
    172.X.X.XXX    clientstate.local



Fig up (this will take forever the first time):

    fig up

Reset the database schema:

    fig run csm bash reset_schema.sh

To test changes:

    fig rm
    fig build
    fig up
    fig run csm bash reset_schema.sh

Go to https://clientstate.local and create an app.

Go to github and create a new app - input the credentials in clientstate.local


Docker should be accessible over tcp eg:

    export DOCKER_OPTS="-H tcp://0.0.0.0:2375"
    export DOCKER_PARENT_HOST="0.0.0.0"
    export DOCKER_PARENT_PORT="2375"
    export DOCKER_HOST="0.0.0.0:2375"
 















Local Hacking
-------------

Assuming you have `node` and `npm` installed,
you can install the dependencies:

    npm install

If you have postgres installed and listening locally,
and that your current user is a passwordless superuser,
you can create the schema for a database `csm`:

    ./reset_schema.sh

The postgres connection details there can be specified with ENV variables,
PG_PORT_5432_TCP_ADDR, PG_PORT_5432_TCP_PORT, PG_USER:

    export PG_PORT_5432_TCP_ADDR=${PG_PORT_5432_TCP_ADDR:="127.0.0.1"}
    export PG_PORT_5432_TCP_PORT=${PG_PORT_5432_TCP_PORT:="5432"}
    export PG_USER=${PG_USER:=$USER}

You can run the server-side tests:

    ./run_tests.sh

You can run the client-side tests:

    ./node_modules/karma/bin/karma start karma.conf.js

You can run the server on port 4000 locally:

    node server.js

Or, with nodemon installed (or similar),
run the server with automatic code reloading:

    nodemon server

You will need the ENV variables to have great success:

    GITHUB_CLIENT_ID
    GITHUB_CLIENT_SECRET
    OAUTH_REDIRECT_URL

Create an app on github, and make the callback url there be:

    http://localhost:4000/auth_callback/github

Then, you can make `OAUTH_REDIRECT_URL=http://localhost:4000`
in the environment:

    OAUTH_REDIRECT_URL=http://localhost:4000 nodemon server

Assuming you have docker installed locally,
you can now create and remove containers through the webUI.

To customize the location of the docker API,
you should be able to set DOCKER_PORT_4444_TCP_ADDR (127.0.0.1 is default)
and DOCKER_PORT_4444_TCP_PORT (2375 is default).
(TODO- 4444. wat?)


Run in Containers
-----------------

Assumes you can call `docker version` from your command line with success.

I'm running on OSX with coreos-vagrant running on the private network,
core1 is at `172.17.8.101`.

I have created a github app with the callback url of:

    http://172.17.8.101:4000/auth_callback/github

Then, in my ENV, I have

    export GITHUB_CLIENT_ID="abc"
    export GITHUB_CLIENT_SECRET="def"
    export OAUTH_REDIRECT_URL="http://172.17.8.101:4000"

Build the containers:

    fig build

Run the containers:

    fig up

In a separate terminal, start a container and create/reset the schema
(TODO- automate):

    fig run csm bash reset_schema.sh

Now, you should be able to go to http://172.17.8.101:4000/
and create/destroy some clientstate-redis containers
