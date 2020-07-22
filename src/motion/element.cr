module Motion
  class Element
    getter raw : JSON::Any

    def initialize(@raw : JSON::Any)
    end

    def tag_name
      raw["tagName"]?
    end

    def value
      raw["value"]?
    end

    def attributes
      raw["attributes"]?
    end

    def [](key : String)
      attributes[key] || attributes[key.tr("_", "-")]
    end

    def id
      self["id"]
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
      return @data unless @data.nil?

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
