require "json"

module Motion
  class Event
    def self.from_raw(raw : JSON::Any)
      new(raw) if raw
    end

    getter raw : JSON::Any

    def initialize(@raw : JSON::Any)
    end

    def type
      raw["type"]
    end

    # alias name type

    def details
      raw.dig?("details")
    end

    def extra_data
      raw["extraData"]
    end

    def target
      return @target if defined?(@target)

      @target = Motion::Element.from_raw(raw["target"])
    end

    def current_target
      return @current_target if defined?(@current_target)

      @current_target = Motion::Element.from_raw(raw["currentTarget"])
    end

    # alias element current_target

    # def form_data
    #   element&.form_data
    # end
  end
end
