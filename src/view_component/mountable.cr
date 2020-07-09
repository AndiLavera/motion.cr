module ViewComponent::Mountable
  # :nodoc:
  def mount(view : ViewComponent::Base.class, *args, **named_args)
    view.new(*args, **named_args).render
  end
end
