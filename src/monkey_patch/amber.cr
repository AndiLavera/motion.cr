# :nodoc:
module Amber
  # :nodoc:
  module Controller
    # :nodoc:
    module Helpers
      # :nodoc:
      module Render
        include Motion::MountComponent
        include Motion::HTML::SpecialtyTags
        @[JSON::Field(ignore: true)]
        getter view = IO::Memory.new

        def render(component : Motion::Base.class)
          m(component)
          view.to_s
        end
      end
    end
  end
end
