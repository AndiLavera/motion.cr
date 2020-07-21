module Motion::Motions
  # :nodoc:
  module Rendering
    # :nodoc:
    def render_hash
      Motion.serializer.weak_digest(self)
    end
  end
end
