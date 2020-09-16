require "redis"
require "json"

module Motion::Adapters
  class Redis < Base
    getter fibers : Hash(String, Fiber) = Hash(String, Fiber).new
    private getter broadcast_streams : Hash(String, Array(String)) = Hash(String, Array(String)).new
    private getter redis : ::Redis::PooledClient = ::Redis::PooledClient.new(url: Motion.config.redis_url)

    def get_component(topic : String) : Motion::Base
      weak_deserialize(redis.get(topic).not_nil!)
    rescue error : NilAssertionError
      raise Motion::Exceptions::NoComponentConnectionError.new(topic)
    end

    def mget_components(topics : String) : Array(Motion::Base)
    end

    def set_component(topic : String, component : Motion::Base)
      redis.set(topic, Motion.serializer.weak_serialize(component))
    end

    def destroy_component(topic : String) : Bool
      !!redis.del(topic)
    end

    def get_broadcast_streams(stream_topic : String) : Array(String)
      redis.lrange(stream_topic, 0, -1).map(&.to_s)
    end

    def set_broadcast_streams(topic : String, component : Motion::Base)
      return unless component.responds_to?(:broadcast_channel)
      channel = component.broadcast_channel

      redis.lpush(channel, topic)
    end

    def destroy_broadcast_stream(topic : String, component : Motion::Base) : Bool
      !!broadcast_streams[component.broadcast_channel].delete(topic)
    end

    def get_periodic_timers(name : String) : Fiber?
      fibers[name]?
    end

    def set_periodic_timers; end

    def destroy_periodic_timers(component : Motion::Base)
      component.periodic_timers.each do |timer|
        if name = timer[:name]
          fibers.delete(name)
          Motion.logger.info("Periodic Timer #{name} has been disabled")
        end
      end
    end
  end
end
