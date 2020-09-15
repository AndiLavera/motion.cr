module Motion::Adapters
  class Server
    getter fibers : Hash(String, Fiber) = Hash(String, Fiber).new
    getter broadcast_streams : Hash(String, Array(String)) = Hash(String, Array(String)).new
    getter components : Hash(String, String) = Hash(String, String).new

    def set_component_connection(topic : String, component : Motion::Base)
      components[topic] = Motion.serializer.weak_serialize(component)
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
      Motion.serializer.weak_deserialize(components[topic]?.not_nil!)
    rescue error : NilAssertionError
      raise Motion::Exceptions::NoComponentConnectionError.new(topic)
    end

    def delete(topic : String)
      components.delete(topic)
    end
  end
end
