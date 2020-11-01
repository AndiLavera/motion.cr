module Motion::Motions
  # :nodoc:
  module Rendering
    # :nodoc:
    def rerender_hash
      Motion.serializer.weak_digest(self)
    end
  end
end
