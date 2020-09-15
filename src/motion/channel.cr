require "json"
require "./message"
require "./connection_manager"

# Please leave this for generating docs
# :nodoc:
abstract class Amber::WebSockets::Channel
end

module Motion
  # :nodoc:
  class Channel < Amber::WebSockets::Channel
    def self.broadcast(stream_topic : String)
      if channel = Amber::WebSockets::ClientSocket.get_topic_channel("motion")
        channel.process_broadcast(stream_topic)
      end
    end

    @connection_manager : Motion::ConnectionManager?

    def handle_joined(client_socket, json : JSON::Any) : Bool
      message = Message.new(json)
      raise_version_mismatch(message.version) if versions_mismatch?(message.version)

      connection_manager.create(message)

      # connection_manager.synchronize(message.topic)
    end

    def handle_leave(client_socket, message : Motion::Message)
      connection_manager.destroy(message)
    end

    def handle_message(client_socket, json : JSON::Any)
      message = Message.new(json)

      case message.command
      when "unsubscribe"
        handle_leave(client_socket, message)
      when "process_motion"
        component = connection_manager.process_motion(message)
        connection_manager.synchronize(component, message.topic)
      end
    end

    def process_model_stream(stream_topic : String)
      connection_manager.process_model_stream(stream_topic)
    end

    # Amber::WebSockets::Channel#rebroadcast! is a protected method
    def rebroadcast!(payload)
      super(payload)
    end

    def connection_manager : Motion::ConnectionManager
      @connection_manager ||= Motion::ConnectionManager.new(self)
    end

    private def versions_mismatch?(client_version) : Bool
      Motion.config.version != client_version
    end

    private def raise_version_mismatch(client_version)
      raise Exceptions::IncompatibleClientError.new(Motion.config.version, client_version)
    end

    private def logger
      Motion.logger
    end
  end
end
