require "json"
require "./html_engine"
require "./logger"
require "./exceptions"
require "./motions"
require "./annotations"
require "./adapters"

abstract class Motion::Base
  include Motion::HTML::Engine
  include Motion::Motions
  include Motion::Adapters

  @[JSON::Field(ignore: true)]
  # :nodoc:
  property view : IO::Memory = IO::Memory.new

  # :nodoc:
  property render_hash : UInt64?

  property motion_component : Bool = false

  # def to_s(io)
  #   io << view
  # end

  # :nodoc:
  def rerender
    self.view = IO::Memory.new
    render
    view.to_s
  end

  # :nodoc:
  macro inherited
    def process_motion(motion : String, event : Motion::Event?)
      {% verbatim do %}
        {% begin %}
          case motion
          {% for method in @type.methods.select &.annotation(Motion::MapMethod) %}

            {% args = method.args %}
            {% if args[0] && !args[0].restriction.resolve == Motion::Event %}
              {% raise "MotionArgumentError: Motions can only accept `Motion::Event` type" %}
            {% end %}

            {% if args.size >= 2 %}
              {% raise "MotionArgumentError: Too many arguments for motion #{@type}##{method.name}" %}
            {% end %}

            when {{method.name.id.stringify}}
              return self.{{method.name.id}}({% if args.size == 1 %}{{"event".id}}{% end %})
          {% end %}
          end
        {% end %}
      {% end %}
    end

    def periodic_timers
      timers = [] of NamedTuple(name: String, method: Proc(Nil), interval: Time::Span)
      {% verbatim do %}
        {% begin %}
          {% for method in @type.methods.select &.annotation(Motion::PeriodicTimer) %}
            timers << {
              name: {{method.name.stringify}},
              method: Proc(Void).new { {{method.name}} },
              interval: {{method.annotation(Motion::PeriodicTimer)[:interval]}},
            }
          {% end %}
        {% end %}
      {% end %}
      timers
    end
  end

  # :nodoc:
  def _process_model_stream; end

  # :nodoc:
  macro subclasses
    {
    {% for subclass in @type.subclasses %}
      {{subclass}}: {{subclass.id}},
    {% end %}
    }
  end
end
