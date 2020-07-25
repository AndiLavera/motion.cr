module Motion
  # Provides an interface for users to access Motion::Channel
  class ChannelInterface
    def initialize(@channel : Motion::Channel)
    end

    def set_state(component : Motion::Base)
      @channel.set_state(component)
    end
  end
end
