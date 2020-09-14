module Motion::Adapter
  class Server
    getter component_connections : Hash(String, Motion::ComponentConnection?) = Hash(String, Motion::ComponentConnection?).new
    getter fibers : Hash(String, Fiber) = Hash(String, Fiber).new
    getter broadcast_streams : Hash(String, Array(String)) = Hash(String, Array(String)).new
  end
end
