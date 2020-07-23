require "../spec_helper"

describe Motion::Event do
  event = create_event

  it "can set targets" do
    event.target.should_not be_nil
    event.current_target.should_not be_nil
    event.element.should_not be_nil
  end

  it "can fetch data" do
    event.details.should_not be_nil
    event.extra_data.should_not be_nil
    event.name.should_not be_nil
    event.type.should_not be_nil
  end
end

private def create_event
  Motion::Event.new(EVENT_DATA)
end
