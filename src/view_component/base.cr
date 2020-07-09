require "./html_builder"

module ViewComponent::Base
  # TODO:
  # Habitat.create do
  #   setting render_component_comments : Bool = false
  # end

  macro included
    include ViewComponent::HTMLBuilder
    getter view = IO::Memory.new
  end

  def to_s(io)
    io << view
  end
end
