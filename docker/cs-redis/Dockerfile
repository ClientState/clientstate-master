FROM ubuntu:14.04

RUN apt-get update
RUN apt-get install -y nodejs npm git git-core

RUN git clone https://github.com/ClientState/clientstate-redis

# set the working directory to run commands from
WORKDIR /clientstate-redis
RUN npm install
# expose the port so host can have access
EXPOSE 3000
# pass env variables in with docker run -e
# GITHUB_CLIENT_ID, GITHUB_CLIENT_SECRET, OAUTH_REDIRECT_URL
CMD ["nodejs", "server.js"]
