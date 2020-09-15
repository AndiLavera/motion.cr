module Motion::Adapters
  class Server
    # getter component_connections : Hash(String, Motion::ComponentConnection?) = Hash(String, Motion::ComponentConnection?).new
    getter fibers : Hash(String, Fiber) = Hash(String, Fiber).new
    getter broadcast_streams : Hash(String, Array(String)) = Hash(String, Array(String)).new

    # Where components will go after changes
    getter components : Hash(String, String) = Hash(String, String).new

    def set_component_connection(topic : String, component : Motion::Base)
      components[topic] = Motion.serializer.serialize_without_digest(component)
    end

    def set_broadcast_streams(topic : String, component : Motion::Base)
      return unless component.responds_to?(:broadcast_channel)

      if broadcast_streams[component.broadcast_channel]?.nil?
        broadcast_streams[component.broadcast_channel] = [topic]
      else
        broadcast_streams[component.broadcast_channel] << topic
      end
    end

    def get(topic : String) : Motion::Base
      Motion.serializer.deserialize(components[topic]?.not_nil!)
    rescue error : NilAssertionError
      raise Motion::Exceptions::NoComponentConnectionError.new(topic)
    end

    def delete(topic : String)
      components.delete(topic)
    end
  end
end
