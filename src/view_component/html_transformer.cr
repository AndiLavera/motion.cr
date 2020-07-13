# require "nokogiri"
# require "active_support/core_ext/object/blank"

# require "motion"

module ViewComponent::Motion
  class HTMLTransformer
    setter serializer : ViewComponent::Motion::Serializer
    setter key_attribute : String
    setter state_attribute : String

    def initialize(
      serializer = Motion.serializer,
      key_attribute = "motion-key",    # TODO: Motion.config.key_attribute,
      state_attribute = "motion-state" # TODO: Motion.config.state_attribute
    )
      @serializer = serializer
      @key_attribute = key_attribute
      @state_attribute = state_attribute
    end

    def add_state_to_html(component, html)
      return if html.blank?

      key, state = serializer.serialize(component)

      transform_root(component, html) do |root|
        root[key_attribute] = key
        root[state_attribute] = state
      end
    end

    private def transform_root(component, html)
      fragment = Myhtml::Parser.new(html)
      root = fragment.root!

      yield root

      fragment.to_html
      # fragment = Nokogiri::HTML::DocumentFragment.parse(html)
      # root, *unexpected_others = fragment.children
      # if !root || unexpected_others.any?(&:present?)
      #   raise MultipleRootsError, component
      # end
      # yield root
      # fragment.to_html.html_safe
    end
  end
end
