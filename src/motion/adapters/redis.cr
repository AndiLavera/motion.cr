require "redis"
require "json"

module Motion::Adapters
  class Redis
    private getter redis : ::Redis

    def initialize
      @redis = ::Redis.new(url: "redis://localhost:6379/0")
      # redis.set("component_connections", "")
      redis.set("fibers", "")
      redis.set("streams", "")
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

    def set_component_connection(topic : String, component_connection : Motion::ComponentConnection)
      redis.set(topic, Motion.serializer.serialize_component_connection(component_connection))
    end

    def set_streams(component_connection, topic)
      component = component_connection.component
      return unless component.responds_to?(:broadcast_channel)

      if streams[component.broadcast_channel]?.nil?
        streams[component.broadcast_channel] = [topic]
      else
        streams[component.broadcast_channel] << topic
      end
    end

    # def set_periodic_timers(topic : String)
    #   get(topic).periodic_timers.each do |timer|
    #     name = timer[:name].to_s
    #     adapter.fibers[name] = spawn do
    #       while connected?(topic) && periodic_timer_active?(name)
    #         proc = ->do
    #           interval = timer[:interval]
    #           sleep interval if interval.is_a?(Time::Span)

    #           method = timer[:method]
    #           method.call if method.is_a?(Proc(Nil))
    #         end

    #         get(topic).process_periodic_timer(proc, name.to_s)
    #         channel.synchronize(topic: topic, broadcast: true)
    #       end
    #     end
    #   end
    # end

    def fibers=(new_fiber); end

    def model_streams=(new_model_stream); end

    # For initial testing. Needs to be removed
    def r
      redis
    end
  end
end
