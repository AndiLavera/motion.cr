require "./adapters/base"
require "./adapters/**"

module Motion
  # Motion has 2 adapters which can be configured through the `Configuration` class. The 2 available selections are `:server` and `:redis`. It's recommended to use `:server` when you only have 1 node. When you have a distributed system, you can use redis as a backend.
  #
  # ```
  # Motion.configure do |config|
  #   config.adapter = :redis
  #   config.redis_url = "my_url"
  #   config.redis_ttl = 30 # In minutes
  # end
  # ```
  module Adapters
  end
end
