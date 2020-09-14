module Motion
  class ConnectionManager
    alias Adapters = Motion::Adapters::Server # | Motion::Adapter::Redis
    getter adapter : Adapters
    getter channel : Motion::Channel

    def initialize(@channel : Motion::Channel)
      # @adapter = Motion.config.adapter == :server ? Adapters::Server.new : Adapters::Redis.new
      @adapter = Motion::Adapters::Server.new
    end

    def create(message : Motion::Message)
      attach_component(message.topic, message.state)
    end

    def destroy(message : Motion::Message)
      topic = message.topic

      get(topic).close do |component|
        destroy_periodic_timers(component)
        destroy_model_streams(component, topic) if component.responds_to?(:broadcast_channel)
        adapter.component_connections.delete(topic)
      end
    end

    def process_motion(message : Motion::Message)
      get(message.topic).process_motion(message.name, message.event)
    end

    def synchronize(topic : String, proc)
      get(topic).if_render_required(proc)
    end

    def process_model_stream(stream_topic)
      topics = adapter.broadcast_streams[stream_topic]?
      if topics && !topics.empty?
        topics.each do |topic|
          component_connection = get(topic)
          component_connection.process_model_stream(stream_topic)
          channel.synchronize(topic, true)
        end
      end
    end

    def get(topic : String) : Motion::ComponentConnection
      adapter.component_connections[topic]?.not_nil!
    rescue error : NilAssertionError
      raise Motion::Exceptions::NoComponentConnectionError.new(topic)
    end

    private def attach_component(topic : String, state : String)
      component_connection = connect_component(state)

      set_component_connection(component_connection, topic)
      set_broadcasts(component_connection, topic)
      set_periodic_timers(topic)
    end

    private def set_component_connection(component_connection : Motion::ComponentConnection, topic : String)
      adapter.component_connections[topic] = component_connection
    end

    private def set_broadcasts(component_connection, topic)
      component = component_connection.component
      if component.responds_to?(:broadcast_channel)
        if adapter.broadcast_streams[component.broadcast_channel]?.nil?
          adapter.broadcast_streams[component.broadcast_channel] = [topic]
        else
          adapter.broadcast_streams[component.broadcast_channel] << topic
        end
      end
    end

    private def set_periodic_timers(topic : String)
      get(topic).periodic_timers.each do |timer|
        name = timer[:name].to_s
        adapter.fibers[name] = spawn do
          while connected?(topic) && periodic_timer_active?(name)
            proc = ->do
              interval = timer[:interval]
              sleep interval if interval.is_a?(Time::Span)

              method = timer[:method]
              method.call if method.is_a?(Proc(Nil))
            end

            get(topic).process_periodic_timer(proc, name.to_s)
            channel.synchronize(topic: topic, broadcast: true)
          end
        end
      end
    end

    private def connect_component(state) : ComponentConnection
      ComponentConnection.from_state(state)
    rescue error : Exception
      # reject
      raise "Exception in connect_component"
      # handle_error(e, "connecting a component")
    end

    private def connected?(topic)
      !get(topic).nil?
    end

    # TODO: Some way to allow users to invoke
    # a method to stop a particular timer
    private def periodic_timer_active?(name)
      true
    end

    private def destroy_periodic_timers(component)
      component.periodic_timers.each do |timer|
        if name = timer[:name]
          adapter.fibers.delete(name)
          logger.info("Periodic Timer #{name} has been disabled")
        end
      end
    end

    private def destroy_model_streams(component, topic)
      adapter.broadcast_streams[component.broadcast_channel].delete(topic)
    end

    private def handle_error(error, context)
      logger.error("An error occurred while #{context} & #{error}")
    end

    private def logger
      Motion.logger
    end
  end
end
