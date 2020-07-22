require "json"

module Motion
  class Event
    def self.from_raw(raw : JSON::Any)
      new(raw) if raw
    end

    getter raw : JSON::Any

    def initialize(@raw : JSON::Any)
      @target = Motion::Element.new(raw["target"])
      @current_target = Motion::Element.new(raw["currentTarget"])
    end

    def type
      raw["type"]?
    end

    def name
      type
    end

    def details
      raw["details"]?
    end

    def extra_data
      raw["extraData"]?
    end

    def target
      @target
    end

    def current_target
      @current_target
    end

    def element
      current_target()
    end

    # def form_data
    #   element&.form_data
    # end
  end
end
