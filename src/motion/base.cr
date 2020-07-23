require "json"
require "./html_engine"
require "./logger"
require "./exceptions"
require "./motions"

# Set this annotation on any methods that can be invoked from the frontend.
#
# Here is a small example setting `MyComponent#add` as a motion:
# ```crystal
# class MyComponent < Motion::Base
#   props count : Int32 = 0
#
#   @[MapMotion]
#   def add
#     count += 1
#   end
# end
# ```
annotation MapMotion; end

class Motion::Base
  include Motion::HTML::Engine
  include Motion::Motions
  include JSON::Serializable

  @[JSON::Field(ignore: true)]
  property view : IO::Memory = IO::Memory.new
  property map_motion : Bool = false

  # def to_s(io)
  #   io << view
  # end

  # :nodoc:
  def rerender
    self.view = IO::Memory.new
    render
  end

  # :nodoc:
  def process_motion(method : String, event : Motion::Event?)
    raise Exceptions::MotionBaseMethodError.new("process_motion")
  end

  # :nodoc:
  def render
    raise Exceptions::MotionBaseMethodError.new("render")
  end

  # :nodoc:
  macro inherited
    def process_motion(motion : String, event : Motion::Event?)
      {% verbatim do %}
        {% begin %}
          case motion
          {% for method in @type.methods.select &.annotation(MapMotion) %}

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
  end

  # :nodoc:
  macro subclasses
    {
    {% for subclass in @type.subclasses %}
      {{subclass}}: {{subclass.id}},
    {% end %}
    }
  end
end
