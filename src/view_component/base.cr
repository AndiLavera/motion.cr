require "./html_builder"
require "./motion"

class ViewComponent::Base
  # TODO:
  # Habitat.create do
  #   setting render_component_comments : Bool = false
  # end

  include ViewComponent::HTMLBuilder
  include ViewComponent::Motion
  getter view = IO::Memory.new

  def to_s(io)
    io << view
  end
end
