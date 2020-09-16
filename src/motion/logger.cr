require "log"

module Motion
  # :nodoc:
  class Logger
    Log = ::Log.for("Motion")

    {% for level in ["info", "warn", "error"] %}
      def {{level.id}}(message) : Nil
        Log.{{level.id}} { message }
      end
    {% end %}

    def timing(&block : -> String) : Nil
      start_time = Time.local
      message = block.call
      end_time = Time.local

      info("#{message} (in #{format_duration(end_time - start_time)})")
    end

    def process_motion_timing(motion : String, &block : -> Motion::Base) : Motion::Base
      start_time = Time.local
      component = block.call
      end_time = Time.local

      info("Proccessed motion #{motion} for component #{component.class} (in #{format_duration(end_time - start_time)})")

      component
    end

    def process_broadcast_stream_timing(&block : -> Tuple(String, Int32)) : Nil
      start_time = Time.local
      message, size = block.call
      end_time = Time.local
      duration = end_time - start_time

      info("#{message} (in #{format_duration(duration)} with an avg time per client of #{average_duration(duration, size)})")
    end

    private def format_exception(exception)
      frames = exception.backtrace.first(BACKTRACE_FRAMES).join("\n")

      "#{exception.class}: #{exception}\n#{indent(frames)}"
    end

    private def format_duration(duration)
      μs = duration.microseconds
      "#{μs.round(1)}μs"
    end

    private def average_duration(duration, size)
      format_duration(duration / size)
    end
  end
end
