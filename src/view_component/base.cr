require "./html_builder"
require "./motion"
require "./exceptions"

class ViewComponent::Base
  # TODO:
  # Habitat.create do
  #   setting render_component_comments : Bool = false
  # end

  include ViewComponent::HTMLBuilder
  include ViewComponent::Motion

  @[Crystalizer::Field(ignore: true)]
  getter view = IO::Memory.new
  property map_motion : Bool = false

  def to_s(io)
    io << view
  end

  macro subclasses
    {% classes = {} of String => ViewComponent::Base %}
    {% for subclass in @type.subclasses %}
      {% classes[subclass.stringify] = subclass %}
    {% end %}
    {{ classes }}
  end
end
