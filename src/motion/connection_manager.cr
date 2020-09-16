module Motion
  class ConnectionManager
    alias Adapters = Motion::Adapters::Server | Motion::Adapters::Redis
    getter adapter : Adapters
    getter channel : Motion::Channel

    # TODO: Shouldn't do Motion.action_timer.my_method(get(topic))
    # get(topic) should be in the blocks as fetching & setting
    # components is something that should be timed.

    def initialize(@channel : Motion::Channel)
      @adapter = Motion.config.adapter == :server ? Motion::Adapters::Server.new : Motion::Adapters::Redis.new
      # @adapter = Motion::Adapters::Server.new
    end

    def create(message : Motion::Message)
      attach_component(message.topic, message.state)
    end

    def destroy(message : Motion::Message)
      topic = message.topic

      Motion.action_timer.close(get_component(topic)) do |component|
        adapter.destroy_periodic_timers(component)
        adapter.destroy_broadcast_stream(topic, component) if component.responds_to?(:broadcast_channel)
        adapter.destroy_component(topic)
      end
    end

    def process_motion(message : Motion::Message) : Motion::Base
      Motion.action_timer.process_motion(get_component(message.topic), message.name, message.event) do |component|
        adapter.set_component(message.topic, component)
      end
    end

    def synchronize(component : Motion::Base, topic : String)
      Motion.action_timer.if_render_required(component) do |component|
        render(component, topic)
      end
    end

    def process_model_stream(stream_topic : String)
      topics = adapter.get_broadcast_streams(stream_topic)
      if topics && !topics.empty?
        topics.each do |topic|
          # TODO: Dont make 10 trips to redis
          # redis can handle redis#mget can handle an array of keys
          # make a Adapter#mget_components(topic) method
          component = get_component(topic)
          Motion.action_timer.process_model_stream(component, stream_topic) do |component|
            # TODO: Dont call process_model_stream on each iterations
            # If someone had 100 users to update, youll blow the logs
            # process_model_stream should accepts all topics & all components
            # log the total time took and the avg per component (time / components)
            adapter.set_component(topic, component)
            synchronize(component, topic)
          end
        end
      end
    end

    def render(component, topic)
      html = Motion.html_transformer.add_state_to_html(component, component.rerender)
      channel.rebroadcast!({
        subject: "message_new",
        topic:   topic,
        payload: {
          html: html,
        },
      })
    end

    private def attach_component(topic : String, state : String) : Bool
      connect_component(state) do |component|
        adapter.set_component(topic, component)
        adapter.set_broadcast_streams(topic, component)
        set_periodic_timers(topic, component)
      end
    end

    private def set_periodic_timers(topic : String, component : Motion::Base)
      component.periodic_timers.each do |periodic_timer|
        name = periodic_timer[:name].to_s

        adapter.fibers[name] = spawn do
          while connected?(name) && periodic_timer_active?(name)
            Motion.action_timer.process_periodic_timer(name.to_s) do
              interval = periodic_timer[:interval]
              sleep interval if interval.is_a?(Time::Span)

              method = periodic_timer[:method]
              method.call if method.is_a?(Proc(Nil))

              # synchronize(topic: topic, broadcast: true)
              synchronize(component, topic)
              # adapter.set_component(topic, component) if connected?(topic)
            end
          end
        end
      end
    end

    private def connect_component(state, &block : Motion::Base -> Nil) : Bool
      Motion.action_timer.connect(Motion.serializer.deserialize(state), &block)
      # rescue error : Exception
      #   # reject
      #   raise "Exception in connect_component"
      #   # handle_error(e, "connecting a component")
    end

    private def get_component(topic : String) : Motion::Base
      adapter.get_component(topic)
    end

    private def connected?(name : String) : Bool
      !!adapter.get_periodic_timers(name)
    end

    # TODO: Some way to allow users to invoke
    # a method to stop a particular timer
    private def periodic_timer_active?(name) : Bool
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
