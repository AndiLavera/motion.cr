require "./spec_helper"

[Motion::Adapters::Redis, Motion::Adapters::Server].each do |adapter_class|
  describe adapter_class do
    before_each do
      Redis.new(url: Motion.config.redis_url).flushdb

      if adapter_class == Motion::Adapters::Redis
        Motion.configure do |config|
          config.adapter = :redis
        end
      end
    end

    after_each do
      Redis.new(url: Motion.config.redis_url).flushdb
      Motion.reset_config
    end

    it "can set a component" do
      adapter = adapter_class.new
      adapter.set_component("motion:69689", TickerComponent.new)
      adapter.get_component("motion:69689").class.should eq(TickerComponent)
    end

    it "can delete a component" do
      adapter = adapter_class.new
      adapter.set_component("motion:6967", MotionRender.new)

      adapter.destroy_component("motion:6967").should be_true
      expect_raises(Motion::Exceptions::NoComponentConnectionError) do
        adapter.get_component("motion:6967")
      end
    end

    it "can set a broadcast stream" do
      component = BroadcastComponent.new
      adapter = adapter_class.new
      adapter.set_broadcast_streams("motion:87892", component)
      adapter.get_broadcast_streams(component.broadcast_channel).should eq(["motion:87892"])
    end
  end
end
