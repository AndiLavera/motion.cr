module Motion
  # :nodoc:
  class ComponentConnection
    # def self.from_state(state)
    #   new(component: Motion.serializer.deserialize(state))
    # end

    # getter component : Motion::Base?
    # getter render_hash : UInt64?

    def initialize; end

    # def initialize(component : Motion::Base, &block : Motion::Base -> Nil)
    #   timing("Connected #{@component.class}") do
    #     component.render_hash = component.rerender_hash
    #     block.call(component)
    #   end
    # end

    def connect(component : Motion::Base, &block : Motion::Base -> Nil)
      timing("Connected #{component.class}") do
        component.render_hash = component.rerender_hash
        block.call(component)
      end
    end

    def close(component : Motion::Base, &block : Motion::Base -> Nil)
      timing("Disconnected #{component.class}") do
        block.call(component)
      end

      true
    rescue error : Exception
      handle_error(error, "disconnecting the component")

      false
    end

    def process_motion(component : Motion::Base, motion : String, event : Motion::Event? = nil, &block : Motion::Base -> Nil)
      timing("Proccessed #{motion}") do
        component.process_motion(motion, event)
        block.call(component)
      end

      true
    rescue error : Exception
      handle_error(error, "processing #{motion}")

      false
    end

    def process_model_stream(component : Motion::Base, stream_topic, &block : Motion::Base -> Nil)
      timing("Proccessed model stream #{stream_topic} for #{component.class}") do
        component._process_model_stream
        block.call(component)
      end

      true
    rescue error : Exception
      handle_error(error, "processing model stream #{stream_topic} for #{component.class}")

      false
    end

    # def process_periodic_timer(timer : Proc(Nil), name : String)
    #   timing("Proccessed periodic timer #{name}") do
    #     # component.process_periodic_timer timer
    #     timer.call
    #   end

    #   true
    # rescue error : Exception
    #   handle_error(error, "processing periodic timer #{timer}")

    #   false
    # end

    def process_periodic_timer(name : String, &block)
      timing("Proccessed periodic timer #{name}") do
        # component.process_periodic_timer timer
        block.call
      end

      true
    rescue error : Exception
      handle_error(error, "processing periodic timer #{name}")

      false
    end

    def if_render_required(component : Motion::Base, proc)
      timing("Rendered") do
        next_render_hash = component.not_nil!.rerender_hash

        next if component.not_nil!.render_hash == next_render_hash
        # && !component.awaiting_forced_rerender?

        proc.call(component.not_nil!)

        component.not_nil!.render_hash = next_render_hash
      end
    rescue error : Exception
      handle_error(error, "rendering the component")
    end

    # def broadcasts
    #   component.broadcasts
    # end

    # def periodic_timers(component : Motion::Base)
    #   component.not_nil!.periodic_timers
    # end

    private def timing(context, &block)
      logger.timing(context, &block)
    end

    private def handle_error(error, context)
      logger.error("An error occurred while #{context}. Error: #{error}")
    end

    private def logger
      Motion.logger
    end
  end
end
