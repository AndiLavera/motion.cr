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
  getter view = IO::Memory.new
  property map_motion : Bool = false

  def to_s(io)
    io << view
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
            when {{method.name.id.stringify}} then return self.{{method.name.id}}    
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
