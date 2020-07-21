require "json"
require "./html_engine"
require "./logger"
require "./exceptions"
require "./motions"

# :nodoc:
annotation MapMotion; end

class Motion::Base
  # TODO:
  # Habitat.create do
  #   setting render_component_comments : Bool = false
  # end

  include Motion::HTML::Engine
  include Motion::Motions
  include JSON::Serializable

  @[JSON::Field(ignore: true)]
  property view : IO::Memory = IO::Memory.new
  property map_motion : Bool = false

  # def to_s(io)
  #   io << view
  # end

  def rerender
    self.view = IO::Memory.new
    render
  end

  def process_motion(method : String, event : Motion::Event?)
    # TODO: Real Error
    raise "Motion::Base#process_motion"
  end

  def render
    # TODO: Real Error
    raise "Motion::Base#render"
  end

  macro inherited
    def process_motion(motion : String, event : Motion::Event?)
      {% verbatim do %}
        {% begin %}
          case motion
          {% for method in @type.methods.select &.annotation(MapMotion) %}

            {% args = method.args %}
            {% if args[0] && !args[0].restriction.resolve == Event %}
              {% raise "MotionArgumentError: Motions can only accept `Event` type" %}
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
  end

  macro subclasses
    {
    {% for subclass in @type.subclasses %}
      {{subclass}}: {{subclass.id}},
    {% end %}
    }
  end
end
