require "json"

module Motion
  class Channel < Amber::WebSockets::Channel
    getter component_connection : Motion::ComponentConnection?
    getter html_transformer : Motion::HTMLTransformer = Motion.html_transformer
    getter logger : Motion::Logger = Motion.logger

    def handle_joined(client_socket, message)
      state = message["identifier"]["state"].to_s
      client_version = message["identifier"]["version"].to_s

      raise_version_mismatch(client_version) if versions_mismatch?(client_version)

      @component_connection = connect_component(state)
      synchronize
    end

    def handle_leave(client_socket)
      # TODO: Remove not_nil
      pp "unsubscribe"
      component_connection.not_nil!.close

      @component_connection = nil
    end

    def handle_message(client_socket, message)
      topic = message["topic"]
      identifier, data, command = parse_motion(message["payload"])

      case command
      when "unsubscribe"    then handle_leave(client_socket)
      when "process_motion" then (process_motion(identifier, data) if data)
      end

      synchronize(topic, broadcast = true)
    end

    def process_motion(identifier, data : JSON::Any)
      motion, raw_event = data["name"], data["event"]

      if (cc = component_connection)
        cc.process_motion(motion.to_s, Motion::Event.from_raw(raw_event))
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

      # periodically_notify component_connection.periodic_timers,
      #   via: :process_periodic_timer
      if broadcast
        proc = ->(component : Motion::Base) {
          html = html_transformer.add_state_to_html(component, component.rerender)
          rebroadcast!({
            subject: "message_new",
            topic:   topic,
            payload: {
              html: html,
            },
          })
        }

        # TODO: Remove not_nil
        component_connection.not_nil!.if_render_required(proc)
      end
    end

    private def parse_motion(payload)
      identifier = payload["identifier"]?
      data = payload["data"]?
      command = payload["command"]?

      [identifier, data, command]
    end

    # TODO: pass error in as an argument: , error: error
    private def handle_error(error, context)
      logger.error("An error occurred while #{context} & #{error}")
    end

    # def process_broadcast(broadcast, message)
    #   component_connection.process_broadcast(broadcast, message)
    #   synchronize
    # end

    # def process_periodic_timer(timer)
    #   component_connection.process_periodic_timer(timer)
    #   synchronize
    # end
  end
end
