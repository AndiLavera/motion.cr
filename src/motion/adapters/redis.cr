require "redis"
require "json"

module Motion::Adapters
  # :nodoc:
  class Redis < Base
    private getter redis : ::Redis::PooledClient = ::Redis::PooledClient.new(url: Motion.config.redis_url)

    def get_component(topic : String) : Motion::Base
      weak_deserialize(redis.get(topic).not_nil!)
    rescue error : NilAssertionError
      raise Motion::Exceptions::NoComponentConnectionError.new(topic)
    end

    def get_components(topics : Array(String)) : Array(Tuple(String, Motion::Base))
      redis.mget(topics).map_with_index do |component, idx|
        {topics[idx], weak_deserialize(component.to_s)}
      end
    end

    def set_component(topic : String, component : Motion::Base) : Bool
      !!redis.set(topic, Motion.serializer.weak_serialize(component))
    end

    def destroy_component(topic : String) : Bool
      !!redis.del(topic)
    end

    def get_broadcast_streams(stream_topic : String) : Array(String)
      redis.lrange(stream_topic, 0, -1).map(&.to_s)
    end

    def set_broadcast_streams(topic : String, component : Motion::Base) : Bool
      return true unless component.responds_to?(:broadcast_channel)

      channel = component.broadcast_channel
      !!redis.lpush(channel, topic)
    end

    def destroy_broadcast_stream(topic : String, component : Motion::Base) : Bool
      return true unless component.responds_to?(:broadcast_channel)

      channel = component.broadcast_channel
      !!redis.lrem(channel, 1, topic)
    end

    def get_periodic_timers : Array(String)
      redis.lrange("periodic_timers", 0, -1).map(&.to_s)
    end

    def set_periodic_timers(topic : String, component : Motion::Base, &block) : Bool
      component.periodic_timers.each do |periodic_timer|
        name = periodic_timer[:name]

        redis.lpush("periodic_timers", name)
        Motion.logger.info("Periodic Timer #{name} has been registered")
        spawn do
          while connected?(name) && periodic_timer_active?(name)
            Motion.action_timer.process_periodic_timer(name) do
              sleep periodic_timer[:interval]
              periodic_timer[:method].call

              block.call
            end
          end
        end
      end

      true
    end

    def destroy_periodic_timers(component : Motion::Base) : Bool
      component.periodic_timers.each do |timer|
        if name = timer[:name]
          !!redis.lrem("periodic_timers", 1, name)
          Motion.logger.info("Periodic Timer #{name} has been deleted")
        end
      end

      true
    end
  end
end
