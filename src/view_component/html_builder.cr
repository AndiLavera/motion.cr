require "./tags/**"
require "./page_helpers/**"
require "./allowed_in_tags"
require "./asset_helpers"
require "./assignable"
require "./mount_component"
require "./mountable"

module ViewComponent::HTMLBuilder
  include ViewComponent::BaseTags
  include ViewComponent::CustomTags
  include ViewComponent::LabelHelpers
  include ViewComponent::InputHelpers
  include ViewComponent::SelectHelpers
  include ViewComponent::SpecialtyTags
  include ViewComponent::Assignable
  include ViewComponent::AssetHelpers
  include ViewComponent::NumberToCurrency
  include ViewComponent::TextHelpers
  include ViewComponent::HTMLTextHelpers
  include ViewComponent::TimeHelpers
  include ViewComponent::ForgeryProtectionHelpers
  include ViewComponent::MountComponent
  include ViewComponent::HelpfulParagraphError
  include ViewComponent::RenderIfDefined
  include ViewComponent::WithDefaults

  abstract def view

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
