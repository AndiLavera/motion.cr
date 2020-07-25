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

    # :nodoc:
    include Rendering

    macro setup_json_hook
      macro finished
        setup_json_serializer
      end

      macro included
        setup_json_hook
      end

      macro inherited
        setup_json_hook
      end
    end

    macro included
      setup_json_hook
    end

    macro setup_json_serializer
      {% if !@type.abstract? %}
        include JSON::Serializable
      {% end %}
    end
  end
end
