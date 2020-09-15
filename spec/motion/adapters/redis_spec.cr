require "./spec_helper"

describe Motion::Adapters::Redis do
  before_each do
    Motion.config.finalized = false

    Motion.configure do |config|
      config.adapter = :redis
    end
  end

  after_each do
    Redis.new(url: Motion.config.redis_url).flushdb
  end

  it "can make a new redis component" do
    json = JSON.parse({
      "topic":      "motion:69689",
      "identifier": {
        "state":   "eyJtb3Rpb25fY29tcG9uZW50Ijp0cnVlLCJjb3VudCI6MH0AVGlja2VyQ29tcG9uZW50", # TickerComponent
        "version": Motion::Version.to_s,
      },
    }.to_json)

    channel = join_channel(json)

    json_component = channel.connection_manager.adapter.redis_get("motion:69689").not_nil!
    component = Motion.serializer.weak_deserialize(json_component)
    component.class.should eq(TickerComponent)
  end
end
