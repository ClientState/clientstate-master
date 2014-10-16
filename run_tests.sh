dropdb csm-test
createdb csm-test
PG_DATABASE=csm-test node create_schema.js
PG_DATABASE=csm-test mocha
