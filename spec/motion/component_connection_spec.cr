require "../spec_helper"

describe Motion::ComponentConnection do
  it "can intialize all dependencies" do
    component_connection =
      Motion::ComponentConnection.new(
        MotionRender.new,
        Motion::ChannelInterface.new(Motion::Channel.new)
      )

    component_connection.render_hash.should_not be_nil
    component_connection.component.should_not be_nil
    component_connection.logger.should_not be_nil
  end

  it "can process a motion" do
    component = MotionMount.new
    component_connection =
      Motion::ComponentConnection.new(
        component,
        Motion::ChannelInterface.new(Motion::Channel.new)
      )

    component.count.should eq(0)
    component_connection.process_motion("add", nil)
    component.count.should eq(1)
  end

  it "can process a motion with event" do
    component = MotionRender.new
    component_connection =
      Motion::ComponentConnection.new(
        component,
        Motion::ChannelInterface.new(Motion::Channel.new)
      )

    component.motion_hit?.should be_false
    component_connection.process_motion("motion", Motion::Event.new(EVENT_DATA))
    component.motion_hit?.should be_true

    puts component.channel.inspect
  end
end
