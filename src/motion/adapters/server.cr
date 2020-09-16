module Motion::Adapters
  class Server < Base
    getter fibers : Hash(String, Fiber) = Hash(String, Fiber).new
    private getter broadcast_streams : Hash(String, Array(String)) = Hash(String, Array(String)).new
    private getter components : Hash(String, String) = Hash(String, String).new

    def get_component(topic : String) : Motion::Base
      weak_deserialize(components[topic]?.not_nil!)
    rescue error : NilAssertionError
      raise Motion::Exceptions::NoComponentConnectionError.new(topic)
    end

    def mget_components(topics : Array(String)) : Array(Motion::Base)
      topics.map { |topic| get_component(topic) }
    end

    def set_component(topic : String, component : Motion::Base) : Bool
      !!(components[topic] = Motion.serializer.weak_serialize(component))
    end

    def destroy_component(topic : String) : Bool
      !!components.delete(topic)
    end

    def get_broadcast_streams(stream_topic : String) : Array(String)
      broadcast_streams[stream_topic]? || [] of String
    end

    def set_broadcast_streams(topic : String, component : Motion::Base) : Bool
      return true unless component.responds_to?(:broadcast_channel)
      channel = component.broadcast_channel

      broadcast_streams[channel] ||= [] of String
      broadcast_streams[channel] << topic

      true
    end

    def destroy_broadcast_stream(topic : String, component : Motion::Base) : Bool
      return true unless component.responds_to?(:broadcast_channel)

      channel = component.broadcast_channel
      !!broadcast_streams[channel].delete(topic)
    end

    def get_periodic_timers(name : String) : Fiber?
      fibers[name]?
    end

    def set_periodic_timers; end

    def destroy_periodic_timers(component : Motion::Base) : Bool
      component.periodic_timers.each do |timer|
        if name = timer[:name]
          fibers.delete(name)
          Motion.logger.info("Periodic Timer #{name} has been disabled")
        end
      end

      true
    end
  end
end
