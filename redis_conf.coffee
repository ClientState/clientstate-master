redis = require "redis"

client = redis.createClient(
  process.env.REDIS_PORT_6379_TCP_PORT or '6379',
  process.env.REDIS_PORT_6379_TCP_ADDR or 'localhost',
  if process.env.REDIS_OPTIONS then JSON.parse(process.env.REDIS_OPTIONS) else {}
)

global.redis_client = client
