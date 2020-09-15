require "../../spec_helper"

module Motion::Adapters
  class Redis
    def redis_get(topic : String)
      @redis.get(topic)
    end
  end

  class Server
    def redis_get(topic : String)
      # @redis.get(topic)
    end
  end
end

def join_channel(json = MESSAGE_JOIN)
  channel = Motion::Channel.new
  channel.handle_joined(nil, json)
  channel
end
