require "../spec_helper"
require "myhtml"

class MotionRender < ViewComponent::Base
  def render
    m MotionMount
    view.to_s
  end
end

class MotionMount < ViewComponent::Base
  props map_motion : Bool = true
  props hello : String = "hello"

  def render
    div do
      div data_motion: "add" do
        h2 "Subheading"
      end
    end
    view.to_s
  end
end

class UnsafeMultipleRootsRender < ViewComponent::Base
  property hello : String = "Name"

  def render
    m UnsafeMultipleRootsMount
    view.to_s
  end
end

class UnsafeMultipleRootsMount < ViewComponent::Base
  property map_motion : Bool = true

  def render
    div do
      div data_motion: "add" do
        h2 "Subheading"
      end
    end
    div do
      h1 "hi"
    end
    view.to_s
  end
end

# describe ViewComponent::Motion::HTMLTransformer do
#   it "can transform markup" do
#     MotionRender.new.render.includes?("motion-state").should be_true
#   end

#   it "throws error when component has multiple roots" do
#     expect_raises(ViewComponent::Motion::MultipleRootsError) do
#       UnsafeMultipleRootsRender.new.render
#     end
#   end
# end

describe ViewComponent::Motion::Serializer do
  it "can deserialize component" do
    fragment = Myhtml::Parser.new(MotionRender.new.render)
    node_with_state = fragment.body!.children.to_a[0]
    state = node_with_state.attribute_by("motion-state")

    raise "Could not find motion-state" if state.nil?

    puts ViewComponent::Motion::Serializer.new.deserialize(state)
    # json = Crystalizer::JSON.serialize MotionRender.new
    # klass = ViewComponent::Base.fetch_subclass("MotionRender")
    # component = Crystalizer::JSON.deserialize(json, to: klass)
    # puts c.inspect
  end
end
