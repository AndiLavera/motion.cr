require "../spec_helper"

[:server, :redis].each do |adapter|
  describe Motion::Channel do
    describe "with #{adapter} adapter" do
      before_each do
        Redis.new(url: Motion.config.redis_url).flushdb

        Motion.configure do |config|
          config.adapter = adapter
        end
      end

      after_each do
        Redis.new(url: Motion.config.redis_url).flushdb
        Motion.reset_config
      end

      it "can handle a new subscriber" do
        channel = Motion::Channel.new
        channel.handle_joined(nil, MESSAGE_JOIN).should be_true
        channel.connection_manager.get_component(MESSAGE_JOIN["topic"].as_s).should_not be_nil
        channel.connection_manager.get_component(MESSAGE_JOIN["topic"].as_s).class.should eq(MotionRender)
      end

      it "raises an error when versions mismatch" do
        json = JSON.parse({
          "topic":      "motion:696890",
          "identifier": {
            "state":   "",
            "version": "2.0.0a",
          },
        }.to_json)

        expect_raises(Motion::Exceptions::IncompatibleClientError) do
          join_channel(json)
        end
      end

      it "raises NoComponentConnectionError on mismatch topic" do
        channel = join_channel
        expect_raises(Motion::Exceptions::NoComponentConnectionError) do
          channel.connection_manager.get_component("bad_topic")
        end
      end

      it "can process a motion" do
        channel = join_channel

        channel.connection_manager.get_component(MESSAGE_JOIN["topic"].as_s).view.to_s.empty?.should be_true

        channel.handle_message(nil, MESSAGE_NEW)
        component = channel.connection_manager.get_component(MESSAGE_JOIN["topic"].as_s)

        component.inspect.to_s.includes?("@motion_hit=true").should be_true
      end

      it "can handle unsubscribe" do
        message = JSON.parse({
          "event"   => "message",
          "topic"   => MESSAGE_JOIN["topic"],
          "subject" => "message_new",
          "payload" => {
            "command"    => "unsubscribe",
            "data"       => {} of String => String,
            "identifier" => {
              "channel" => MESSAGE_JOIN["topic"],
              "version" => Motion::Version.to_s,
              "state"   => "eyJtYXBfbW90aW9uIjpmYWxzZSwibW90aW9uX2hpdCI6ZmFsc2V9AE1vdGlvblJlbmRlcg==", # MotionRender
            },
          },
        }.to_json)

        channel = join_channel

        channel.handle_message(nil, message)
        expect_raises(Motion::Exceptions::NoComponentConnectionError) do
          channel.connection_manager.adapter.get_component(message["topic"].as_s)
        end
      end

      it "can register periodic timers" do
        json = JSON.parse({
          "topic":      "motion:6968129",
          "identifier": {
            "state":   "eyJtb3Rpb25fY29tcG9uZW50Ijp0cnVlLCJjb3VudCI6MH0AVGlja2VyQ29tcG9uZW50", # TickerComponent
            "version": Motion::Version.to_s,
          },
        }.to_json)

        channel = join_channel(json)

        channel.connection_manager.adapter.get_test_fibers.empty?.should be_false
      end

      # pending("can run periodic timers")

      it "can register broadcast streams" do
        json = JSON.parse({
          "topic":      "motion:6932689",
          "identifier": {
            "state":   Motion.serializer.serialize(BroadcastComponent.new).last,
            "version": Motion::Version.to_s,
          },
        }.to_json)

        channel = join_channel(json)
        channel.connection_manager.adapter.get_broadcast_streams("todos:created").empty?.should be_false
      end

      it "can process broadcast streams" do
        json = JSON.parse({
          "topic":      "motion:69689",
          "identifier": {
            "state":   Motion.serializer.serialize(BroadcastComponent.new).last,
            "version": Motion::Version.to_s,
          },
        }.to_json)

        channel = join_channel(json)
        channel.process_model_stream("todos:created")
        component = channel.connection_manager.get_component("motion:69689")
        component.inspect.to_s.includes?("@count=1").should be_true
      end
    end
  end
end

def join_channel(json = MESSAGE_JOIN)
  channel = Motion::Channel.new
  channel.handle_joined(nil, json)
  channel
end
