module Motion
  # :nodoc:
  class ComponentConnection
    def initialize; end

    def connect(component : Motion::Base, &block : Motion::Base -> Nil) : Bool
      timing("Connected #{component.class}") do
        component.render_hash = component.rerender_hash
        block.call(component)
      end

      true
    rescue error : Exception
      handle_error(error, "disconnecting the component")

      false
    end

    def close(component : Motion::Base, &block : Motion::Base -> Nil) : Bool
      timing("Disconnected #{component.class}") do
        block.call(component)
      end

      true
    rescue error : Exception
      handle_error(error, "disconnecting the component")

      false
    end

    def process_motion(component : Motion::Base, motion : String, event : Motion::Event? = nil, &block : Motion::Base -> Nil) : Motion::Base
      timing("Proccessed #{motion}") do
        component.process_motion(motion, event)
        block.call(component)
      end

      component
      # rescue error : Exception
      #   handle_error(error, "processing #{motion}")

      #   false
    end

    def process_model_stream(component : Motion::Base, stream_topic, &block : Motion::Base -> Nil) : Bool
      timing("Proccessed model stream #{stream_topic} for #{component.class}") do
        component._process_model_stream
        block.call(component)
      end

      true
    rescue error : Exception
      handle_error(error, "processing model stream #{stream_topic} for #{component.class}")

      false
    end

    def process_periodic_timer(name : String, &block) : Bool
      timing("Proccessed periodic timer #{name}") do
        block.call
      end

      true
    rescue error : Exception
      handle_error(error, "processing periodic timer #{name}")

      false
    end

    def if_render_required(component : Motion::Base, &block : Motion::Base -> Nil) : Bool
      timing("Rendered") do
        next_render_hash = component.rerender_hash

        next if component.render_hash == next_render_hash
        # && !component.awaiting_forced_rerender?

        block.call(component)
        component.render_hash = next_render_hash
      end

      true
    rescue error : Exception
      handle_error(error, "rendering the component")

      false
    end

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
