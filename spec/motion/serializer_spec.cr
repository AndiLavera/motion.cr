require "../spec_helper"

describe Motion::Serializer do
  it "can deserialize component" do
    fragment = Myhtml::Parser.new(MotionRender.new.render)
    node_with_state = fragment.body!.children.to_a[0]
    state = node_with_state.attribute_by("data-motion-state")

    raise "Could not find motion-state" if state.nil?
    deserialized_component = Motion::Serializer.new.deserialize(state)

    deserialized_component.inspect.to_s.includes?("@test_prop=\"Test Prop\"").should be_true
    deserialized_component.inspect.to_s.includes?("@map_motion=true").should be_true
  end
end
