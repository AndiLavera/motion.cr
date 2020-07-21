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
end
