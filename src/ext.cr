module Motion
  module EXT
    module Renderer
      macro included
        include Motion::MountComponent
        include Motion::HTML::SpecialtyTags
        @[JSON::Field(ignore: true)]
        getter view = IO::Memory.new

        def mount(component : Motion::Base.class)
          m(component)
          view.to_s
        end
      end
    end

    module Stream
      def self.stream(stream_topic : String)
        if channel = get_topic_channel("motion")
          channel.process_model_stream(stream_topic)
        end
      end
    end
  end
end
