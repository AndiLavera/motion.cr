require "json"

# Please leave this for generating docs
# :nodoc:
abstract class Amber::WebSockets::Channel
end

module Motion
  # :nodoc:
  class Channel < Amber::WebSockets::Channel
    property component_connections : Hash(String, Motion::ComponentConnection?) = Hash(String, Motion::ComponentConnection?).new
    # getter component_connection : Motion::ComponentConnection?
    # property topic : String?
    property fibers : Array(Fiber) = [] of Fiber

    def handle_joined(client_socket, message)
      client_version = message["identifier"]["version"].to_s
      raise_version_mismatch(client_version) if versions_mismatch?(client_version)

      state = message["identifier"]["state"].as_s
      topic = message["topic"].to_s
      self.component_connections[topic] = connect_component(state)

      process_periodic_timer(topic)
      synchronize(topic)
    end

    def handle_leave(client_socket, message)
      pp "HANDLE LEAVE"
      pp message
      # TODO: Remove not_nil
      # component_connection.not_nil!.close
      # @component_connection = nil
    end

    def handle_message(client_socket, message)
      topic = message["topic"].as_s
      identifier, data, command = parse_motion(message["payload"])

      case command
      when "unsubscribe"
        handle_leave(client_socket)
        broadcast = false
      when "process_motion"
        if data
          process_motion(identifier, data, topic)
          broadcast = true
        end
      end

      synchronize(topic, broadcast)
    end

    def process_motion(identifier, data : JSON::Any, topic : String)
      motion, raw_event = data["name"], data["event"]

      if (cc = component_connections[topic])
        cc.process_motion(motion.to_s, Motion::Event.new(raw_event))
      else
        raise "NoComponentConnectionError"
      end
    end

    private def versions_mismatch?(client_version)
      Motion.config.version != client_version
    end

    private def raise_version_mismatch(client_version)
      raise Exceptions::IncompatibleClientError.new(Motion.config.version, client_version)
    end

    private def connect_component(state)
      ComponentConnection.from_state(state)
    rescue e : Exception
      # reject
      handle_error(e, "connecting a component")
    end

    private def synchronize(topic = nil, broadcast = false)
      # streaming_from component_connection.broadcasts,
      #   to: :process_broadcast

      if broadcast
        proc = ->(component : Motion::Base) {
          render(component, topic)
        }

        # TODO: Remove not_nil
        component_connections[topic].not_nil!.if_render_required(proc)
      end
    end

    private def parse_motion(payload)
      identifier = payload["identifier"]?
      data = payload["data"]?
      command = payload["command"]?

      [identifier, data, command]
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

    # TODO: pass error in as an argument: , error: error
    private def handle_error(error, context)
      Motion.logger.error("An error occurred while #{context} & #{error}")
    end

    # def process_broadcast(broadcast, message)
    #   component_connection.process_broadcast(broadcast, message)
    #   synchronize
    # end

    private def process_periodic_timer(topic)
      component_connections[topic].not_nil!.periodic_timers.each do |timer|
        name = timer[:name]
        self.fibers << spawn name: name.to_s do
          while connected?(topic) && periodic_timer_active?(name)
            proc = ->do
              interval = timer[:interval]
              sleep interval if interval.is_a?(Time::Span)

              method = timer[:method]
              method.call if method.is_a?(Proc(Nil))
            end

            component_connections[topic].not_nil!.process_periodic_timer(proc, name.to_s)

            synchronize(topic: topic broadcast: true)
          end
        end
      end
    end

    private def connected?(topic)
      !component_connections[topic]?.nil?
    end

    # TODO: Some way to allow users to invoke
    # a method to stop a particular timer
    private def periodic_timer_active?(name)
      true
    end
  end
end
