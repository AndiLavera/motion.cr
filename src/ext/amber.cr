require "../ext"

# :nodoc:
module Amber
  # :nodoc:
  module Controller
    # :nodoc:
    class Base
      include Motion::EXT::Renderer
    end
  end

  # :nodoc:
  module WebSockets
    # :nodoc:
    struct ClientSocket
      # :nodoc:
      include Motion::EXT::Stream
    end
  end
end
