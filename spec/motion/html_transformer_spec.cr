require "../spec_helper"
require "myhtml"

describe Motion::HTMLTransformer do
  it "can transform markup" do
    c = MotionRender.new
    c.render
    c.view.to_s.includes?("motion-state").should be_true
  end

  it "throws error when component has multiple roots" do
    expect_raises(Motion::Exceptions::MultipleRootsError) do
      UnsafeMultipleRootsRender.new.render
    end
  end
end
