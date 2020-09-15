require "./version"

module Motion
  # Main configuration for Motion.cr.
  #
  # In `config/initializers/motion.cr`
  # ```crystal
  # Motion.configure do |config|
  #   config.render_component_comments = true
  # end
  # ```
  class Configuration
    # If true, 2 comments will be added at rendering signifying
    # the start & end of a component. Really helpful for debugging.
    #
    # Defaults to true
    property render_component_comments : Bool = true

    # Set the adapter for where deserialized components are stored.
    # Accepts either `:server` or `:redis`. If set to `:server`
    # component connections will be stored in memory on the server.
    # `:redis` requires you to set the `redis_url`.
    property adapter : Symbol = :server

    # Set the redis url if you are using the redis adapter
    #
    # Defaults to `"redis://localhost:6379/0"`
    property redis_url : String = "redis://localhost:6379/0"

    # Set the TTL property for components in minutes.
    #
    # Motion removes components after a page offloads, however
    # it is best to set a ttl in case any components do not get
    # offloaded.
    property redis_ttl : Int32 = 180

    # :nodoc:
    property finalized : Bool = false

    # :nodoc:
    getter serializer : Motion::Serializer = Motion::Serializer.new

    # :nodoc:
    getter html_transformer : Motion::HTMLTransformer = Motion::HTMLTransformer.new

    # :nodoc:
    getter timer : ComponentConnection = ComponentConnection.new

    # :nodoc:
    getter logger : Motion::Logger = Motion::Logger.new

    # :nodoc:
    getter version : String = Motion::Version.to_s
  end
end
