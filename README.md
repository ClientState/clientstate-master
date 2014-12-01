# ClientState

Login with $provider, input your secrets, get slick JS APIs to databases.

This is the hub that launches your containers and keeps track of your secrets.


## Launch in Containers Locally

### Dependencies

Install Docker. https://docs.docker.com/installation/

Install Fig. http://www.fig.sh/install.html

### Prepare to fig up

###### Clone the repo:

    git clone https://github.com/ClientState/clientstate-master 

###### Generate a self-signed certificate:

    cd clientstate-master/docker/nginx/certs
    # see http://www.akadia.com/services/ssh_test_certificate.html 
    openssl genrsa -des3 -out server.key 1024
    openssl req -new -key server.key -out server.csr
    # remove passphrase
    cp server.key server.key.org
    openssl rsa -in server.key.org -out server.key
    # self-sign
    openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt

###### Git the service submodule(s) and build the docker image:

    git submodule init
    git submodule update
    cd docker/clientstate-service
    docker build -t skyl/clientstate-service .

Make sure you can use docker without sudo (google).

###### Setup Github and OAuth

The only auth that is supported initially is OAuth with github.

[Create an app on github](https://github.com/settings/applications) 
whose auth callback url is `https://clientstate.local/auth_callback/github`

Add the environment variables to you local shell:

    # these are for the clientstate.local app itself
    export GITHUB_CLIENT_ID="e2fbb380.. your id here"
    export GITHUB_CLIENT_SECRET="94d4d2eb9194f.. your secret here"    
    export OAUTH_REDIRECT_URL="https://clientstate.local"


###### Server name is important for routing
Point clientstate.local to your docker host add a line to /etc/hosts
If docker is running on the same host:

    0.0.0.0         clientstate.local

If docker is running in a virtualbox, maybe:

    172.17.8.101    clientstate.local


### Fig

Docker needs to be accessible over `tcp`, for instance:

    export DOCKER_OPTS="-H tcp://0.0.0.0:2375"
    export DOCKER_HOST="0.0.0.0:2375"

Also, we let the webapp know:

    export DOCKER_PARENT_HOST="0.0.0.0"
    export DOCKER_PARENT_PORT="2375"

Fig up (this will take forever the first time):

    fig up

Reset the database schema (in another terminal):

    fig run csm bash reset_schema.sh

Later, you can change things and test changes with:

    fig rm
    fig build
    fig up
    fig run csm bash reset_schema.sh

### Launch the child app

Go to https://clientstate.local and create an app,
you could name it `sweet-app`.

Go to github and create a new app, `sweet-app`.
This time, make the auth callback be:

    https://<appid>.clientstate.local

Input the github credentials for `sweet-app`
into the webapp at clientstate.local.
`OAUTH_REDIRECT_URL` is where your static webpage will be,
for instance, `http://localhost:9001` or `http://baz.github.io/foobar`

Hit LAUNCH button.

### Connect with a client

Add another line in your /etc/hosts file
so that we can hit the backend with a client:

    0.0.0.0         <appid>.clientstate.local

Or, perhaps:

    172.17.8.101    <appid>.clientstate.local

Now you can launch sweetapp as a webpage at
http://localhost:9001 with
[clientstate-js](https://github.com/ClientState/clientstate-js)
enabled.

Instantiate the client with your `appid` and `clientstate.local`
as the host.

    cs = new ClientState(<appid>, "clientstate.local");
    callback = function(error, provider_data) {
        // cs.access_token is now set to provider_data.access_token
    }
    cs.auth_popup("github", <github_client_id_for_sweetapp>, callback)

Once `cs.access_token` is set, you may call the API with
`cs.get` and `cs.post`, for instance.
Read more: https://github.com/ClientState/clientstate-js

(TODO: more clients)

(TODO: USE LOCAL VOLUMES SO YOU CAN HACK WITHOUT REBUILD ALL IMAGES)


## Hack local local

Sometimes you may want to launch the webapp more simply,
without invoking docker to launch the service.
Also, the tests run against a local postgres.
(TODO: completely dockerize the test/develop cycle)

Assuming you have postgres, redis, docker and node installed.

You can install the dependencies:

    npm install

If you have postgres installed and listening locally,
and that your current user is a passwordless superuser,
you can create the schema for a database `csm`:

    ./reset_schema.sh

The postgres connection details there can be specified with ENV variables,
`PG_PORT_5432_TCP_ADDR`, `PG_PORT_5432_TCP_PORT`, `PG_USER`:

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
you should be able to set,

* `DOCKER_PORT_4444_TCP_ADDR` (127.0.0.1 is default)
* `DOCKER_PORT_4444_TCP_PORT` (2375 is default).

(TODO- 4444. wat?)
