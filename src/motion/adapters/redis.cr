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

    def set_component(topic : String, component : Motion::Base)
      redis.set(topic, Motion.serializer.weak_serialize(component))
    end

    def set_broadcast_streams(topic : String, component : Motion::Base)
      return unless component.responds_to?(:broadcast_channel)
      channel = component.broadcast_channel

      if broadcast_streams[channel]?.nil?
        broadcast_streams[channel] = [topic]
      else
        broadcast_streams[channel] << topic
      end
    end

    def get(topic : String) : Motion::Base
      Motion.serializer.weak_deserialize(redis.get(topic).not_nil!)
    rescue error : NilAssertionError
      raise Motion::Exceptions::NoComponentConnectionError.new(topic)
    end

    def delete(topic : String) : Bool
      !!redis.del(topic)
    end

    def get_broadcast_streams(stream_topic : String) : Array(String)?
      broadcast_streams[stream_topic]?
    end

    def destroy_broadcast_stream(topic : String, component : Motion::Base) : Bool
      !!broadcast_streams[component.broadcast_channel].delete(topic)
    end
  end
end
