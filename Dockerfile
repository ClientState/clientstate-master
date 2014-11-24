FROM node
# Debian GNU/Linux jessie/sid
MAINTAINER Skylar Saveland

RUN apt-get install -y postgresql-client

ADD . /src
WORKDIR /src
RUN npm install
RUN ./node_modules/bower/bin/bower install --allow-root

EXPOSE 4000
CMD ["node", "/src/server.js"]

