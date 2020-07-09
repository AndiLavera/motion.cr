module ViewComponent::Mountable
  # :nodoc:
  macro mount(view)
    {{view}}.new.render
  end
end
