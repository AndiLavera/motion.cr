module ViewComponent::Motion
  module Component
    module Rendering
      def render_hash
        # TODO
        # Motion.serializer.weak_digest(self)
        ViewComponent::Motion::Serializer.new.weak_digest(self)
      end
    end
  end
end
