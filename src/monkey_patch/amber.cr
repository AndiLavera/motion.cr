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
      end
    end
  end
end
