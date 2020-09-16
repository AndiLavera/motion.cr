module Motion
  # :nodoc:
  class ActionTimer
    def initialize; end

    # "Connects" a component to the server
    # Sets the jsonified component including any streams & periodic timers
    def connect(&block : -> Motion::Base) : Bool
      timing do
        component = block.call
        "Connected #{component.class}"
      end

      true
    rescue error : Exception
      handle_error(error, "disconnecting the component")

      false
    end

    # Deletes the component, streams & timers
    def close(&block : -> Motion::Base) : Bool
      timing do
        component = block.call
        "Disconnected #{component.class}"
      end

      true
    rescue error : Exception
      handle_error(error, "disconnecting the component")

      false
    end

    def process_motion(motion : String, &block : -> Motion::Base) : Motion::Base
      processed_component = process_motion_timing(motion) do
        block.call
      end

      processed_component
      # rescue error : Exception
      #   handle_error(error, "processing #{motion}")

      #   false
    end

    def process_model_stream(stream_topic, &block : -> Array(Tuple(String, Motion::Base))) : Bool
      process_broadcast_stream_timing do
        components_with_topics = block.call
        size = components_with_topics.size
        {"Proccessed model stream #{stream_topic} for #{size} clients", size}
      end

      true
    rescue error : Exception
      handle_error(error, "processing model stream #{stream_topic}") # for #{component.class}

      false
    end

    def process_periodic_timer(name : String, &block) : Bool
      timing do
        block.call
        "Proccessed periodic timer #{name}"
      end

      true
    rescue error : Exception
      handle_error(error, "processing periodic timer #{name}")

      false
    end

    # If the component requires a render, the block will be called, render and send the new html
    def if_render_required(component : Motion::Base, &block : -> Nil) : Bool
      timing do
        next_render_hash = component.rerender_hash

        next "No Render Required" if component.render_hash == next_render_hash
        # && !component.awaiting_forced_rerender?

        block.call
        component.render_hash = next_render_hash

        "Rendered #{component.class}"
      end

      true
    rescue error : Exception
      handle_error(error, "rendering the component")

      false
    end

    private def timing(&block : -> String)
      logger.timing(&block)
    end

    private def process_broadcast_stream_timing(&block : -> Tuple(String, Int32))
      logger.process_broadcast_stream_timing(&block)
    end

    private def process_motion_timing(motion : String, &block : -> Motion::Base)
      logger.process_motion_timing(motion, &block)
    end

    private def handle_error(error, context)
      logger.error("An error occurred while #{context}. Error: #{error}")
    end

    private def logger
      Motion.logger
    end
  end
end
