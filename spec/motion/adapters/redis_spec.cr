require "../../spec_helper"

def join_channel(json = MESSAGE_JOIN)
  channel = Motion::Channel.new
  channel.handle_joined(nil, json)
  channel
end

describe Motion::Adapters::Redis do
  it "can make a new redis component" do
    # json = JSON.parse({
    #   "topic":      "motion:69689",
    #   "identifier": {
    #     "state":   "eyJtb3Rpb25fY29tcG9uZW50Ijp0cnVlLCJjb3VudCI6MH0AVGlja2VyQ29tcG9uZW50", # TickerComponent
    #     "version": Motion::Version.to_s,
    #   },
    # }.to_json)

    # channel = join_channel(json)

    # if c = channel.connection_manager.adapter.r.get("motion:69689")
    #   pp JSON.parse(c)
    # end
  end
end
