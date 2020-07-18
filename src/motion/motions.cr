require "./motions/*"
require "./html_transformer"
require "./serializer"
require "./component_connection"
require "./motion_channel"
require "./event"
require "./element"

module Motion
  module Motions
    # include Broadcasts
    # include Lifecycle
    # include Motions
    # include PeriodicTimers
    include Rendering
  end
end
