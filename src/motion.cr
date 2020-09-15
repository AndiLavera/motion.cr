require "wordsmith"
require "./motion/configuration"
require "./motion/base"

module Motion
  @@config : Configuration = Configuration.new

  # Main entry for configuring Motion. See `Motion::Configuration` for more details.
  #
  # In `config/initializers/motion.cr`
  # ```crystal
  # Motion.configure do |config|
  #   config.render_component_comments = true
  # end
  # ```
  def self.configure
    raise Exceptions::AlreadyConfiguredError.new if @@config.finalized

    yield @@config

    @@config.finalized = true
  end

  # :nodoc:
  def self.config
    @@config
  end

  # :nodoc:
  def self.serializer
    @@config.serializer
  end

  # :nodoc:
  def self.html_transformer
    @@config.html_transformer
  end

  # :nodoc:
  def self.logger
    @@config.logger
  end

  # :nodoc:
  def self.action_timer
    @@config.action_timer
  end
end
