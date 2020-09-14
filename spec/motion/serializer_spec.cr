require "../spec_helper"

describe Motion::Serializer do
  it "can serialize a component" do
    serializer = Motion::Serializer.new
    digest, state = serializer.serialize(MotionRender.new(test_bool: true))

    digest.is_a?(String).should be_true
    state.is_a?(String).should be_true
    digest.empty?.should be_false
    state.empty?.should be_false
  end

  it "can deserialize a component" do
    serializer = Motion::Serializer.new
    state = serializer.serialize(MotionRender.new(test_bool: true))[1]

    deserialized_component = serializer.deserialize(state)

    deserialized_component.inspect.to_s.includes?("@motion_hit=false").should be_true
    deserialized_component.inspect.to_s.includes?("@test_bool=true").should be_true
  end
end
