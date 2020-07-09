module ViewComponent::Mountable
  macro mount(view)
    {{view}}.new.render
  end
end
