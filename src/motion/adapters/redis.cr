require "redis"
require "json"

module Motion::Adapters
  class Redis
    getter fibers : Hash(String, Fiber) = Hash(String, Fiber).new
    private getter broadcast_streams : Hash(String, Array(String)) = Hash(String, Array(String)).new

    private getter redis : ::Redis

    def initialize
      @redis = ::Redis.new(url: Motion.config.redis_url)
      # redis.set("component_connections", "")
      # redis.set("fibers", "")
      # redis.set("streams", "")
    end

    # def components
    #   if components = redis.get("components")
    #     return JSON.parse(components)
    #   else
    #     raise "RedisComponentConnectionError"
    #   end
    # end

    # def fibers
    #   if fibers = redis.get("fibers")
    #     return JSON.parse(fibers)
    #   else
    #     raise "RedisFiberError"
    #   end
    # end

    # def model_streams
    #   if model_streams = redis.get("model_streams")
    #     return JSON.parse(model_streams)
    #   else
    #     raise "RedisModelStreamError"
    #   end
    # end

    def get_component(topic : String) : Motion::Base
      Motion.serializer.weak_deserialize(redis.get(topic).not_nil!)
    rescue error : NilAssertionError
      raise Motion::Exceptions::NoComponentConnectionError.new(topic)
    end

    def set_component(topic : String, component : Motion::Base)
      redis.set(topic, Motion.serializer.weak_serialize(component))
    end

    def destroy_component(topic : String) : Bool
      !!redis.del(topic)
    end

    def get_broadcast_streams(stream_topic : String) : Array(::Redis::RedisValue)
      redis.lrange(stream_topic, 0, -1)
    end

    def set_broadcast_streams(topic : String, component : Motion::Base)
      return unless component.responds_to?(:broadcast_channel)
      channel = component.broadcast_channel

      redis.lpush(channel, topic)
    end

    def destroy_broadcast_stream(topic : String, component : Motion::Base) : Bool
      !!broadcast_streams[component.broadcast_channel].delete(topic)
    end

    def get_periodic_timers; end

    def set_periodic_timers; end

    def destroy_periodic_timers; end
  end
end
