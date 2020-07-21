require "myhtml"

module Motion
  # :nodoc:
  class HTMLTransformer
    private property key_attribute : String = "data-motion-key"
    private property state_attribute : String = "data-motion-state"

    def add_state_to_html(component, html)
      return if html.nil?

      key, state = serializer.serialize(component)

      transform_root(component, html) do |root|
        root[key_attribute] = key
        root[state_attribute] = state
      end
    end

    private def transform_root(component, html)
      fragment = Myhtml::Parser.new(html)

      if fragment.body!.children.size != 1
        raise Exceptions::MultipleRootsError.new(component)
      end

      # `Myhtml::Parser.new` adds missing elements such as `html`, `head` & `body`.
      # Because of this, we need to build a new string as the return value.
      #
      # `fragment.body!` returns everything inside the body including the body tag.
      # However, `.children` returns the first child of the body
      # tag, which is the componment that we are trying to process.
      String.build do |io|
        fragment.body!.children.each do |root|
          yield root
          root.to_html(io)
        end
      end
    end

    private def serializer
      Motion.serializer
    end
  end
end
