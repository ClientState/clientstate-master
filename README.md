ClientState
===========

Login with $provider, input your secrets, get slick JS APIs to databases.

This is the hub that launches your containers and keeps track of your secrets.


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

In a separate terminal,
start a container,
open a terminal and create/reset the schema
(TODO- automate):

    $ fig run csm /bin/bash
    root@9619c01d242c:/src# PG_USER=postgres ./reset_schema.sh
    dropdb: database removal failed: ERROR:  database "csm" does not exist
    User created
    App created
    ProviderLoginDetails created
    ProviderIDSecret created
    Service created
    Container created

Now, you should be able to go to http://172.17.8.101:4000/
and create/destroy some clientstate-redis containers
