require "redis"
require "json"

module Motion::Adapters
  class Redis
    # getter component_connections : Hash(String, Motion::ComponentConnection?) = Hash(String, Motion::ComponentConnection?).new
    # getter fibers : Hash(String, Fiber) = Hash(String, Fiber).new
    # getter broadcast_streams : Hash(String, Array(String)) = Hash(String, Array(String)).new

    private getter redis : ::Redis

    def initialize
      @redis = ::Redis.new(url: "redis://localhost:6379/0")
      @redis.set("component_connections", "")
      @redis.set("fibers", "")
      @redis.set("model_streams", "")
    end

    def get(s : String)
      redis.get(s)
    end

    def component_connections
      if component_connection = redis.get("component_connections")
        return JSON.parse(component_connections)
      else
        raise "RedisComponentConnectionError"
      end
    end

    def fibers
      if fibers = redis.get("fibers")
        return JSON.parse(fibers)
      else
        raise "RedisFiberError"
      end
    end

    def model_streams
      if model_streams = redis.get("model_streams")
        return JSON.parse(model_streams)
      else
        raise "RedisModelStreamError"
      end
    end

    def set_component_connection(topic, new_connection : Hash(Symbol, String))
      redis.hset(topic, new_connection)
    end

    def fibers=(new_fiber); end

    def model_streams=(new_model_stream); end
  end
end
