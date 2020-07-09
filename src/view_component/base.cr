require "./html_builder"

class ViewComponent::Base
  # TODO:
  # Habitat.create do
  #   setting render_component_comments : Bool = false
  # end

  include ViewComponent::HTMLBuilder
  getter view = IO::Memory.new

  def to_s(io)
    io << view
  end
end
