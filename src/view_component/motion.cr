# require "./motions/*"
# require "./html_transformer"

module ViewComponent
  module Motion
    # def self.configure(&block)
    #   raise AlreadyConfiguredError if @config

    #   @config = Configuration.new(&block)
    # end

    # def self.config
    #   @config ||= Configuration.default
    # end

    def self.serializer
      @@serializer ||= Serializer.new
    end

    def self.markup_transformer
      @@markup_transformer ||= MarkupTransformer.new
    end

    # def self.build_renderer_for(websocket_connection)
    #   config.renderer_for_connection_proc.call(websocket_connection)
    # end

    # def self.notify_error(error, message)
    #   config.error_notification_proc&.call(error, message)
    # end

    # This method only exists for testing. Changing configuration while Motion is
    # in use is not supported. It is only safe to call this method when no
    # components are currently mounted.
    def self.reset_internal_state_for_testing!(new_configuration = nil)
      @@config = new_configuration
      @@serializer = nil
      @@markup_transformer = nil
    end
  end
end
