require "redis"
require "json"

module Motion::Adapters
  class Redis
    getter component_connections : Hash(String, Motion::ComponentConnection?) = Hash(String, Motion::ComponentConnection?).new
    getter fibers : Hash(String, Fiber) = Hash(String, Fiber).new
    getter broadcast_streams : Hash(String, Array(String)) = Hash(String, Array(String)).new

    @redis : ::Redis = ::Redis.new(url: "redis://:my-secret-pw@my.redis.com:6380/my-database")
  end
end
