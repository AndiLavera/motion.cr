module Motion
  module Motions
    module Broadcasts
      # Set's the component to listen for messages, when a message is sent,
      # all components listening will go through a forced rerender.
      #
      # `channel` is the channel the component will listen on such as `"todos:created"`.
      #
      # `method` is the callback method which will be invoked before rerendering.
      #
      # In your component: `stream_from "todos:created", "my_callback_method"` Then anywhere in your application, you can do `MotionSocket.stream("todos:created")` to send a message. Replace `MotionSocket` with the socket class you use for motion.cr.
      macro stream_from(channel, method)
        getter broadcast_channel : String = {{channel.id.stringify}}

        def _process_model_stream
          {{method.id}}
        end
      end
    end
  end
end
