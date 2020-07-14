module ViewComponent::MountComponent
  # Appends the `component` to the view.
  #
  # When `ViewComponent::HTMLPage.settings.render_component_comments` is
  # set to `true`, it will render HTML comments showing where the component
  # starts and ends.
  #
  # ```
  # m(MyComponent)
  # m(MyComponent, with_args: 123)
  # ```
  def m(component_class : ViewComponent::Base.class, *args, **named_args) : Nil
    print_component_comment(component_class) do
      component = component_class.new(*args, **named_args)

      render_and_transform(component)
    end
  end

  # Appends the `component` to the view. Takes a block, and yields the
  # args passed to the component.
  #
  # When `ViewComponent::HTMLPage.settings.render_component_comments` is
  # set to `true`, it will render HTML comments showing where the component
  # starts and ends.
  #
  # ```
  # m(MyComponent, name: "Jane") do |name|
  #   text name.upcase
  # end
  # ```
  def m(component_class : ViewComponent::Base.class, *args, **named_args) : Nil
    print_component_comment(component_class) do
      component = component_class.new(*args, **named_args).render do |*yield_args|
        yield *yield_args
      end

      render_and_transform(component)
    end
  end

  private def print_component_comment(component_class : ViewComponent::Base.class) : Nil
    if true # TODO: ViewComponent::HTMLPage.settings.render_component_comments
      raw "<!-- BEGIN: #{component_class.name} -->"
      yield
      raw "<!-- END: #{component_class.name} -->"
    else
      yield
    end
  end

  private def render_and_transform(component : ViewComponent::Base)
    html = component.render

    if component.map_motion
      html = Motion::HTMLTransformer.new.add_state_to_html(component, html)
    end
    view << html
  end
end
