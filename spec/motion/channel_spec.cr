require "../spec_helper"

describe Motion::Channel do
  it "can handle a new subscriber" do
    channel = Motion::Channel.new
    channel.handle_joined(nil, MESSAGE_JOIN)

    channel.component_connection.should_not be_nil
    channel.component_connection.not_nil!.component.class.should eq(MotionRender)
  end

  it "raises an error when versions mismatch" do
    json = {
      "identifier": {
        "state":   "",
        "version": "2.0.0a",
      },
    }

    expect_raises(Motion::Exceptions::IncompatibleClientError) do
      Motion::Channel.new.handle_joined(nil, json)
    end
  end

  it "can process a motion" do
    channel = Motion::Channel.new
    channel.handle_joined(nil, MESSAGE_JOIN)

    channel.handle_message(nil, MESSAGE_NEW)
    component = channel.component_connection.not_nil!.component
    (c = component) ? c.inspect.to_s.includes?("@motion_hit=true") : fail("No component found")
  end

  it "can handle a subscriber leaving" do
    message = JSON.parse({
      "event"   => "message",
      "topic"   => "motion:922",
      "subject" => "message_new",
      "payload" => {
        "command"    => "unsubscribe",
        "data"       => {} of String => String,
        "identifier" => {} of String => String,
      },
    }.to_json)

    channel = Motion::Channel.new
    channel.handle_joined(nil, MESSAGE_JOIN)

    channel.handle_message(nil, message)
    channel.component_connection.should be_nil
  end
end
