require "../spec_helper"

describe Motion::Channel do
  it "can handle a new subscriber" do
    channel = Motion::Channel.new
    channel.handle_joined(nil, MESSAGE_JOIN)

    channel.component_connections[MESSAGE_JOIN["topic"]].should_not be_nil
    channel.component_connections[MESSAGE_JOIN["topic"]].not_nil!.component.class.should eq(MotionRender)
  end

  it "raises an error when versions mismatch" do
    json = {
      "topic":      "motion:6968",
      "identifier": {
        "state":   "",
        "version": "2.0.0a",
      },
    }

    expect_raises(Motion::Exceptions::IncompatibleClientError) do
      join_channel(json)
    end
  end

  it "can process a motion" do
    channel = join_channel

    channel.handle_message(nil, MESSAGE_NEW)
    component = channel.component_connections[MESSAGE_JOIN["topic"]].not_nil!.component
    (c = component) ? c.inspect.to_s.includes?("@motion_hit=true") : fail("No component found")
  end

  it "can handle unsubscribe" do
    message = JSON.parse({
      "event"   => "message",
      "topic"   => "motion:6968",
      "subject" => "message_new",
      "payload" => {
        "command"    => "unsubscribe",
        "data"       => {} of String => String,
        "identifier" => {
          "channel" => "motion:6968",
          "version" => Motion::Version.to_s,
          "state"   => "eyJtYXBfbW90aW9uIjpmYWxzZSwibW90aW9uX2hpdCI6ZmFsc2V9AE1vdGlvblJlbmRlcg==",
        },
      },
    }.to_json)

    channel = join_channel

    channel.handle_message(nil, message)
    channel.component_connections[message["topic"]]?.should be_nil
  end

  it "can register periodic timers" do
    json = {
      "topic":      "motion:69689",
      "identifier": {
        "state":   "eyJtb3Rpb25fY29tcG9uZW50Ijp0cnVlLCJjb3VudCI6MH0AVGlja2VyQ29tcG9uZW50", # TickerComponent
        "version": Motion::Version.to_s,
      },
    }

    channel = join_channel(json)

    channel.fibers.empty?.should be_false
  end

  pending("it can run periodic timers")
end

def join_channel(json = MESSAGE_JOIN)
  channel = Motion::Channel.new
  channel.handle_joined(nil, json)
  channel
end
