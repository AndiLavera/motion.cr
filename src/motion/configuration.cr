module Motion
  class Configuration
    property render_component_comments : Bool = true
    property finalized : Bool = false

    # We don't want anyone overriding these when configuring
    getter serializer : Motion::Serializer = Motion::Serializer.new
    getter html_transformer : Motion::HTMLTransformer = Motion::HTMLTransformer.new
    getter logger : Motion::Logger = Motion::Logger.new
  end
end
