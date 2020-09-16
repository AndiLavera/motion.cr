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

    private def format_exception(exception)
      frames = exception.backtrace.first(BACKTRACE_FRAMES).join("\n")

      "#{exception.class}: #{exception}\n#{indent(frames)}"
    end

    private def format_duration(duration)
      μs = duration.microseconds
      μs < 0.1 ? "less than 0.1μs" : "#{μs.round(1)}μs"
    end
  end
end
