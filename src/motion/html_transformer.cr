require "myhtml"

module Motion
  class HTMLTransformer
    private property serializer : Motion::Serializer
    private property key_attribute : String
    private property state_attribute : String

    def initialize(
      @serializer = Serializer.new,     # Motion.serializer,
      @key_attribute = "motion-key",    # TODO: Motion.config.key_attribute,
      @state_attribute = "motion-state" # TODO: Motion.config.state_attribute
    )
    end

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
  end
end
