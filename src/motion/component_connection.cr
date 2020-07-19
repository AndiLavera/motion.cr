module Motion
  # :nodoc:
  class ComponentConnection
    # TODO: Motion.serializer,
    def self.from_state(state, serializer = Serializer.new, logger = Motion::Logger.new)
      component = serializer.deserialize(state)

      # TODO: logger.for_component(component)
      new(component: component, logger: logger)
    end

    getter component : Motion::Base
    getter render_hash : String?
    getter logger : Motion::Logger

    # TOOD: LogHelper.for_component(component)
    def initialize(@component : Motion::Base, @logger = Motion::Logger.new)
      timing("Connected") do
        @render_hash = component.render_hash
        # puts render_hash
        # component.process_connect
      end
    end

    def close
      #   timing("Disconnected") do
      #     component.process_disconnect
      #   end

      #   true
      # rescue => error
      #   handle_error(error, "disconnecting the component")

      #   false
    end

    def process_motion(motion : String, event : Motion::Event? = nil)
      timing("Proccessed #{motion}") do
        component.process_motion(motion, event)
      end

      true
    rescue error : Exception
      handle_error(error, "processing #{motion}")

      false
    end

    # def process_broadcast(broadcast, message)
    #   timing("Proccessed broadcast to #{broadcast}") do
    #     component.process_broadcast broadcast, message
    #   end

    #   true
    # rescue => error
    #   handle_error(error, "processing a broadcast to #{broadcast}")

    #   false
    # end

    # def process_periodic_timer(timer)
    #   timing("Proccessed periodic timer #{timer}") do
    #     component.process_periodic_timer timer
    #   end

    #   true
    # rescue => error
    #   handle_error(error, "processing periodic timer #{timer}")

    #   false
    # end

    def if_render_required(proc)
      timing("Rendered") do
        next_render_hash = component.render_hash

        next if @render_hash == next_render_hash
        # && !component.awaiting_forced_rerender?

        proc.call(component)

        @render_hash = next_render_hash
      end
    rescue error : Exception
      handle_error(error, "rendering the component")
    end

    # def broadcasts
    #   component.broadcasts
    # end

    # def periodic_timers
    #   component.periodic_timers
    # end

    private def timing(context, &block)
      logger.timing(context, &block)
    end

    private def handle_error(error, context)
      logger.error("An error occurred while #{context}. Error: #{error}")
    end
  end
end
