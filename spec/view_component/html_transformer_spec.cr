require "../spec_helper"
require "myhtml"

class MotionRender < Motion::Base
  def render
    m MotionMount
    view.to_s
  end
end

class MotionMount < Motion::Base
  props map_motion : Bool = true
  props test_prop : String = "Test Prop"
  props count : Int32 = 0

  @[Invokeable]
  def add
    @count += 1
  end

  def render
    div do
      div data_motion: "add" do
        h2 @count.to_s
      end
    end
    view.to_s
  end
end

class UnsafeMultipleRootsRender < Motion::Base
  property hello : String = "Name"

  def render
    m UnsafeMultipleRootsMount
    view.to_s
  end
end

class UnsafeMultipleRootsMount < Motion::Base
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

describe Motion::HTMLTransformer do
  it "can transform markup" do
    MotionRender.new.render.includes?("motion-state").should be_true
  end

  it "throws error when component has multiple roots" do
    expect_raises(Motion::MultipleRootsError) do
      UnsafeMultipleRootsRender.new.render
    end
  end
end

describe Motion::Serializer do
  it "can deserialize component" do
    fragment = Myhtml::Parser.new(MotionRender.new.render)
    node_with_state = fragment.body!.children.to_a[0]
    state = node_with_state.attribute_by("motion-state")

    raise "Could not find motion-state" if state.nil?
    deserialized_component = Motion::Serializer.new.deserialize(state)

    deserialized_component.inspect.to_s.includes?("@test_prop=\"Test Prop\"").should be_true
    deserialized_component.inspect.to_s.includes?("@map_motion=true").should be_true
    deserialized_component.invoke("add")
    deserialized_component.inspect.to_s.includes?("@count=1").should be_true
  end
end
