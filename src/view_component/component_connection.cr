module ViewComponent::Motion
  class ComponentConnection
    def self.from_state(
      state,
      serializer = Serializer.new, # TODO: Motion.serializer,
      log_helper = nil             # LogHelper.new,
      # **named_args
    )
      component = serializer.deserialize(state)

      new(component,
        log_helper: nil, # log_helper.for_component(component),
        # **named_args
      )
    end

    getter component : ViewComponent::Base

    def initialize(component : ViewComponent::Base,
                   log_helper = nil # TOOD: LogHelper.for_component(component)
                   )
      @component = component
      # @log_helper = log_helper

      # timing("Connected") do
      #   @render_hash = component.render_hash
      #   component.process_connect
      # end
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

    # def process_motion(motion, event = nil)
    #   timing("Proccessed #{motion}") do
    #     component.process_motion(motion, event)
    #   end

    #   true
    # rescue => error
    #   handle_error(error, "processing #{motion}")

    #   false
    # end

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

    # def if_render_required(&block)
    #   timing("Rendered") do
    #     next_render_hash = component.render_hash

    #     return if @render_hash == next_render_hash &&
    #       !component.awaiting_forced_rerender?

    #     yield(component)

    #     @render_hash = next_render_hash
    #   end
    # rescue => error
    #   handle_error(error, "rendering the component")
    # end

    # def broadcasts
    #   component.broadcasts
    # end

    # def periodic_timers
    #   component.periodic_timers
    # end

    # private

    # attr_reader :log_helper

    # def timing(context, &block)
    #   log_helper.timing(context, &block)
    # end

    # def handle_error(error, context)
    #   log_helper.error("An error occurred while #{context}", error: error)
    # end
  end
end
