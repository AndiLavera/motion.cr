require "json"

module Motion
  class Event
    getter raw : JSON::Any

    def initialize(@raw : JSON::Any)
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
      @target ||= Motion::Element.new(raw["target"])
    end

    def current_target
      @current_target ||= Motion::Element.new(raw["currentTarget"])
    end

    def element
      current_target()
    end

    # def form_data
    #   element&.form_data
    # end
  end
end
