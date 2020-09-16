require "spec"
require "http"
require "./support/amber_fixtures"
require "../src/motion"
require "./support/model_fixtures"
require "./support/json_fixtures"

def join_channel(json = MESSAGE_JOIN)
  channel = Motion::Channel.new
  channel.handle_joined(nil, json)
  channel
end

module Motion::Adapters
  class Redis
    def get_test_fibers
      @fibers
    end
  end

  class Server
    def get_test_fibers
      @fibers
    end
  end
end
