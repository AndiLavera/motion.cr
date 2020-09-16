require "../spec_helper"

describe Motion::ConnectionManager do
  pending("ConnectionManager Specs?")

  it "can process multiple broadcast streams at once" do
    component_connection = Motion::ConnectionManager.new(Motion::Channel.new)
    component = BroadcastComponent.new

    ["motion:87092", "motion:81292", "motion:87834"].each do |topic|
      component_connection.adapter.set_component(topic, component)
      component_connection.adapter.set_broadcast_streams(topic, component)
    end

    component_connection.process_model_stream(component.broadcast_channel).should be_true
  end
end
