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

    def handle_joined(client_socket, json)
      message = Message.new(json)
      raise_version_mismatch(message.version) if versions_mismatch?(message.version)

      connection_manager.create(message)

      synchronize(message.topic)
    end

    def handle_leave(client_socket, message : Motion::Message)
      connection_manager.destroy(message)
    end

    def handle_message(client_socket, json : JSON::Any)
      message = Message.new(json)
      broadcast = false

      case message.command
      when "unsubscribe"
        handle_leave(client_socket, message)
      when "process_motion"
        # TODO: Right now the component is being deserialized, process motion, serialized, stored
        # then in channel#synchronize being deserialized to render
        # connection_manager.process_motion should return the component for rendering
        connection_manager.process_motion(message)
        broadcast = true
      end

      synchronize(message.topic, broadcast)
    end

    def process_model_stream(stream_topic : String)
      connection_manager.process_model_stream(stream_topic)
    end

    def synchronize(topic = nil, broadcast = false)
      # streaming_from component_connection.broadcasts,
      #   to: :process_broadcast

      if broadcast
        proc = ->(component : Motion::Base) {
          render(component, topic)
        }

        connection_manager.synchronize(topic, proc)
      end
    end

    private def render(component, topic)
      html = Motion.html_transformer.add_state_to_html(component, component.rerender)
      rebroadcast!({
        subject: "message_new",
        topic:   topic,
        payload: {
          html: html,
        },
      })
    end

    def connection_manager
      @connection_manager ||= Motion::ConnectionManager.new(self)
    end

    private def versions_mismatch?(client_version)
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
