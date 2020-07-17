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

    def timing(message, &block)
      start_time = Time.local
      result = block.call
      end_time = Time.local

      info("#{message} (in #{format_duration(end_time - start_time)})")

      result
    end

    private def format_exception(exception)
      frames = exception.backtrace.first(BACKTRACE_FRAMES).join("\n")

      "#{exception.class}: #{exception}\n#{indent(frames)}"
    end

    private def format_duration(duration)
      duration_ms = duration * 1000
      duration_ms.milliseconds < 0.1 ? "less than 0.1ms" : "#{duration_ms.milliseconds.round(1)}ms"
    end
  end
end
