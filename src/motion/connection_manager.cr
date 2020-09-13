module Motion
  class ConnectionManager
    # TODO: Remove nilable
    getter component_connections : Hash(String, Motion::ComponentConnection?) = Hash(String, Motion::ComponentConnection?).new
    getter fibers : Hash(String, Fiber) = Hash(String, Fiber).new
    getter broadcast_streams : Hash(String, Array(String)) = Hash(String, Array(String)).new
    getter channel : Motion::Channel

    def initialize(@channel : Motion::Channel); end

    def create(message : Motion::Message)
      set_component(message.topic, message.state)
    end

    def destroy(message : Motion::Message)
      topic = message.topic

      get(topic).close do |component|
        component.periodic_timers.each do |timer|
          if name = timer[:name]
            fibers.delete(name)
            logger.info("Periodic Timer #{name} has been disabled")
          end
        end
        component_connections.delete(topic)
      end
    end

    def process_motion(message : Motion::Message)
      get(message.topic).process_motion(message.name, message.event)
    end

    def synchronize(topic : String, proc)
      get(topic).if_render_required(proc)
    end

    def process_periodic_timer(topic : String)
      get(topic).periodic_timers.each do |timer|
        name = timer[:name].to_s
        self.fibers[name] = spawn do
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

    def process_model_stream(stream_topic)
      topics = broadcast_streams[stream_topic]?
      if topics && !topics.empty?
        topics.each do |topic|
          component_connection = get(topic)
          component_connection.process_model_stream(stream_topic)
          channel.synchronize(topic, true)
        end
      end
    end

    def get(topic : String) : Motion::ComponentConnection
      self.component_connections[topic]?.not_nil!
    rescue error : NilAssertionError
      raise Motion::Exceptions::NoComponentConnectionError.new(topic)
    end

    private def set_component(topic : String, state : String)
      component_connection = connect_component(state)
      self.component_connections[topic] = component_connection
      set_broadcasts(component_connection, topic)
    end

    private def set_broadcasts(component_connection, topic)
      component = component_connection.component
      if component.responds_to?(:broadcast_channel)
        if broadcast_streams[component.broadcast_channel]?.nil?
          broadcast_streams[component.broadcast_channel] = [topic]
        else
          broadcast_streams[component.broadcast_channel] << topic
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

    private def handle_error(error, context)
      logger.error("An error occurred while #{context} & #{error}")
    end

    private def logger
      Motion.logger
    end
  end
end
