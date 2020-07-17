module Motion::Motions
  module Rendering
    def render_hash
      # TODO
      # Motion.serializer.weak_digest(self)
      Motion::Serializer.new.weak_digest(self)
    end
  end
end
