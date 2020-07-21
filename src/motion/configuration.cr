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
    # :nodoc:
    property finalized : Bool = false
    # :nodoc:
    getter serializer : Motion::Serializer = Motion::Serializer.new
    # :nodoc:
    getter html_transformer : Motion::HTMLTransformer = Motion::HTMLTransformer.new
    # :nodoc:
    getter logger : Motion::Logger = Motion::Logger.new
    # :nodoc:
    getter version : String = Motion::Version.to_s
  end
end
