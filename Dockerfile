FROM node
# Debian GNU/Linux jessie/sid
MAINTAINER Skylar Saveland

RUN apt-get update
RUN apt-get install -y postgresql-client

WORKDIR /src
EXPOSE 4000
