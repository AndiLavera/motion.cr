module Motion
  class Element
    def self.from_raw(raw : JSON::Any)
      new(raw) if raw
    end

    getter raw : JSON::Any

    def initialize(@raw : JSON::Any)
    end

    def tag_name
      raw["tagName"]
    end

    def value
      raw["value"]
    end

    def attributes
      raw.dig?("attributes")
    end

    def [](key)
      key = key.to_s

      attributes[key] || attributes[key.tr("_", "-")]
    end

    def id
      self[:id]
    end

    private class DataAttributes
      getter element : Motion::Element

      def initialize(@element : Motion::Element)
      end

      def [](data)
        element["data-#{data}"]
      end
    end

    def data
      return @data if defined?(@data)

      @data = DataAttributes.new(self)
    end

    # def form_data
    #   return @form_data if defined?(@form_data)

    #   @form_data =
    #     ActionController::Parameters.new(
    #       Rack::Utils.parse_nested_query(
    #         raw.fetch("formData", "")
    #       )
    #     )
    # end
  end
end
