module Motion
  module Socket
    # :nodoc:
    def self.broadcast(stream_topic : String)
      if channel = get_topic_channel("motion")
        channel.process_broadcast(stream_topic)
      end
    end
  end
end
