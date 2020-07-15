require "./html_builder"
require "./motion"
require "./exceptions"
require "json"

class ViewComponent::Base
  # TODO:
  # Habitat.create do
  #   setting render_component_comments : Bool = false
  # end

  include ViewComponent::HTMLBuilder
  include ViewComponent::Motion
  include JSON::Serializable

  @[JSON::Field(ignore: true)]
  getter view = IO::Memory.new
  property map_motion : Bool = false

  def to_s(io)
    io << view
  end

  macro subclasses
    {
    {% for subclass in @type.subclasses %}
      {{subclass}}: {{subclass.id}},
    {% end %}
    }
  end
end
