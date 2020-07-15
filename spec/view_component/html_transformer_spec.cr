require "../spec_helper"

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

describe ViewComponent::Motion::HTMLTransformer do
  it "can transform markup" do
    MotionRender.new.render.includes?("motion-state").should be_true
  end

  it "throws error when component has multiple roots" do
    expect_raises(ViewComponent::Motion::MultipleRootsError) do
      UnsafeMultipleRootsRender.new.render
    end
  end

  # it "can deserialize component" do
  #   # TODO:
  #   json = Crystalizer::JSON.serialize UnsafeMotionRender.new
  #   klass = ViewComponent::Base.subclasses["UnsafeMotionRender"]
  #   # puts klass
  #   c = Crystalizer::JSON.deserialize(json, to: klass)
  #   puts c.inspect
  #   # MotionRender.new.render
  # end
end
