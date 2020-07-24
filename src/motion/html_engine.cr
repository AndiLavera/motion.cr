require "./html/tags/**"
require "./html/page_helpers/**"
require "./html/allowed_in_tags"
require "./html/asset_helpers"
require "./html/assignable"
require "./mount_component"

module Motion::HTML::Engine
  include BaseTags
  include CustomTags
  include LabelHelpers
  include InputHelpers
  include SelectHelpers
  include SpecialtyTags
  include Assignable
  include AssetHelpers
  include NumberToCurrency
  include TextHelpers
  include HTMLTextHelpers
  include TimeHelpers
  include ForgeryProtectionHelpers
  include MountComponent
  include HelpfulParagraphError
  include RenderIfDefined
  include WithDefaults

  abstract def view
  # :nodoc:
  abstract def render

  macro setup_initializer_hook
    macro finished
      generate_needy_initializer
    end

    macro included
      setup_initializer_hook
    end

    macro inherited
      setup_initializer_hook
    end
  end

  macro included
    setup_initializer_hook
  end

  macro generate_needy_initializer
    {% if !@type.abstract? %}
      {% sorted_assigns = ASSIGNS.sort_by { |dec|
           has_explicit_value =
             dec.type.is_a?(Metaclass) ||
               dec.type.types.map(&.id).includes?(Nil.id) ||
               dec.value ||
               dec.value == nil ||
               dec.value == false
           has_explicit_value ? 1 : 0
         } %}

      def initialize(
        {% for declaration in sorted_assigns %}
          {% var = declaration.var %}
          {% type = declaration.type %}
          {% value = declaration.value %}
          {% value = nil if type.stringify.ends_with?("Nil") && !value %}
          {% has_default = value || value == false || value == nil %}
          @{{ var.id }} : {{ type }}{% if has_default %} = {{ value }}{% end %},
        {% end %}
        **unused_exposures
        )
      end
    {% end %}
  end

  # :nodoc:
  def perform_render : IO
    render
    view
  end
end
