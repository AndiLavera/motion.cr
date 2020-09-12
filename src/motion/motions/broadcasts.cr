module Motion
  module Motions
    module Broadcasts
      macro stream_from(channel, method)
        getter broadcast_channel : String = {{channel.stringify}}

        def _handle_broadcast
          {{method.id}}
        end
      end
    end
  end
end
