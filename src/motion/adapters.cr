require "./adapters/**"

module Motion
  module Adapters
    include Redis
    include Server
  end
end
