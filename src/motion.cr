require "wordsmith"
require "./motion/configuration"
require "./motion/base"

module Motion
  @@config : Configuration = Configuration.new

  def self.configure
    raise Exceptions::AlreadyConfiguredError.new if @@config.finalized

    yield @@config

    @@config.finalized = true
  end

  def self.config
    @@config
  end

  def self.serializer
    @@config.serializer
  end

  def self.html_transformer
    @@config.html_transformer
  end

  def self.logger
    @@config.logger
  end

  # TODO:
  # def self.build_renderer_for(websocket_connection)
  #   config.renderer_for_connection_proc.call(websocket_connection)
  # end

  # def self.notify_error(error, message)
  #   config.error_notification_proc&.call(error, message)
  # end

  # This method only exists for testing. Changing configuration while Motion is
  # in use is not supported. It is only safe to call this method when no
  # components are currently mounted.
  # def self.reset_internal_state_for_testing!(new_configuration = nil)
  #   @@config = new_configuration
  #   @@serializer = nil
  #   @@markup_transformer = nil
  # end
end
