FROM node
# Debian GNU/Linux jessie/sid
MAINTAINER Skylar Saveland

ADD . /src
WORKDIR /src
RUN apt-get install -y postgresql-client
RUN npm install

EXPOSE 4000
CMD ["node", "/src/server.js"]
