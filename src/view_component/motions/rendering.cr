module ViewComponent::Motions
  module Rendering
    def render_hash
      # TODO
      # Motion.serializer.weak_digest(self)
      ViewComponent::Serializer.new.weak_digest(self)
    end
  end
end
