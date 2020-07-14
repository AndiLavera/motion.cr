require "../spec_helper"

class MotionRender < ViewComponent::Base
  def render
    m MotionMount
    view.to_s
  end
end

class MotionMount < ViewComponent::Base
  property map_motion : Bool = true

  def render
    div do
      div data_motion: "add" do
        h2 "Subheading"
      end
    end
    view.to_s
  end
end

describe ViewComponent::Motion::HTMLTransformer do
  it "can transform markup" do
    MotionRender.new.render.should eq(<<-HTML
    <!-- BEGIN: MotionMount --><div motion-key="1234" motion-state="5678"><div data-motion="add"><h2>Subheading</h2></div></div><!-- END: MotionMount -->
    HTML
    )
  end
end
