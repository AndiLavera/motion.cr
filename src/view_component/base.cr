require "json"
require "./html_builder"
require "./logger"
require "./exceptions"
require "./motion"

annotation Invokeable; end

class ViewComponent::Base
  # TODO:
  # Habitat.create do
  #   setting render_component_comments : Bool = false
  # end

  include ViewComponent::HTMLBuilder
  include ViewComponent::Motion
  include ViewComponent::Motion::Component
  include JSON::Serializable

  @[JSON::Field(ignore: true)]
  getter view = IO::Memory.new
  property map_motion : Bool = false

  def to_s(io)
    io << view
  end

  def invoke(method : String)
    # TODO: Real Error
    raise "ViewComponent::Base#invoke"
  end

  def render
    raise "ViewComponent::Base#render"
  end

  macro inherited
    def invoke(method : String)
      {% verbatim do %}
          {% begin %}
            case method
            {% for method in @type.methods.select &.annotation(Invokeable) %}
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
