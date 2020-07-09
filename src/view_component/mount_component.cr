module ViewComponent::MountComponent
  # Appends the `component` to the view.
  #
  # When `ViewComponent::HTMLPage.settings.render_component_comments` is
  # set to `true`, it will render HTML comments showing where the component
  # starts and ends.
  #
  # ```
  # mount MyComponent.new
  # ```
  @[Deprecated("Use `#m` instead. Example: m(MyComponent, arg1: 123)")]
  def mount(component : ViewComponent::BaseComponent) : Nil
    print_component_comment(component.class) do
      component.view(view).render
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
  # mount MyComponent.new("jane") do |name|
  #   text name.upcase
  # end
  # ```
  @[Deprecated("Use `#m` instead. Example: m(MyComponent, arg1: 123) do/end")]
  def mount(component : ViewComponent::BaseComponent) : Nil
    print_component_comment(component.class) do
      component.view(view).render do |*yield_args|
        yield *yield_args
      end
    end
  end

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
  def m(component : ViewComponent::BaseComponent.class, *args, **named_args) : Nil
    print_component_comment(component) do
      component.new(*args, **named_args).view(view).render
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
  def m(component : ViewComponent::BaseComponent.class, *args, **named_args) : Nil
    print_component_comment(component) do
      component.new(*args, **named_args).view(view).render do |*yield_args|
        yield *yield_args
      end
    end
  end

  private def print_component_comment(component : ViewComponent::BaseComponent.class) : Nil
    if ViewComponent::HTMLPage.settings.render_component_comments
      raw "<!-- BEGIN: #{component.name} #{component.file_location} -->"
      yield
      raw "<!-- END: #{component.name} -->"
    else
      yield
    end
  end
end
