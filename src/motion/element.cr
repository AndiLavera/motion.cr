module Motion
  class Element
    getter raw : JSON::Any
    getter form_data : JSON::Any?

    def initialize(@raw : JSON::Any)
    end

    def tag_name
      raw["tagName"]?
    end

    def name
      tag_name
    end

    def value
      raw["value"]?
    end

    def attributes
      raw["attributes"]? || {} of String => String
    end

    def [](key : String)
      attributes[key]? || attributes[key.tr("_", "-")]?
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
      @data ||= DataAttributes.new(self)
    end

    # TODO: Test
    def form_data
      @form_data ||= raw["formData"]?
    end
  end
end
