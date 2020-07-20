module Motion::Motions
  module Rendering
    def render_hash
      Motion.serializer.weak_digest(self)
    end
  end
end
