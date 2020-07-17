require "./tags/**"
require "./page_helpers/**"
require "./allowed_in_tags"
require "./asset_helpers"
require "./assignable"
require "./mount_component"

module Motion::HTMLBuilder
  include Motion::BaseTags
  include Motion::CustomTags
  include Motion::LabelHelpers
  include Motion::InputHelpers
  include Motion::SelectHelpers
  include Motion::SpecialtyTags
  include Motion::Assignable
  include Motion::AssetHelpers
  include Motion::NumberToCurrency
  include Motion::TextHelpers
  include Motion::HTMLTextHelpers
  include Motion::TimeHelpers
  include Motion::ForgeryProtectionHelpers
  include Motion::MountComponent
  include Motion::HelpfulParagraphError
  include Motion::RenderIfDefined
  include Motion::WithDefaults

  abstract def view
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

      # Generate JSON::Serilizable annotions
      {% for declaration in sorted_assigns %}
        {% var = declaration.var %}
        {% type = declaration.type %}
        {% value = declaration.value %}
        {% value = nil if type.stringify.ends_with?("Nil") && !value %}
        {% has_default = value || value == false || value == nil %}
        {{ "@".id }}[JSON::Field(key: {{ var.stringify }})]
        property {{ var.id }} : {{ type }}{% if has_default %} = {{ value }}{% end %}
      {% end %}

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

  macro generate_getters
    {% if !@type.abstract? %}
      {% for declaration in ASSIGNS %}
        {% if declaration.type.stringify == "Bool" %}
          getter? {{ declaration }}
        {% else %}
          getter {{ declaration }}
        {% end %}
      {% end %}
    {% end %}
  end

  def perform_render : IO
    render
    view
  end
end
