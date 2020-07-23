require "../spec_helper"

describe Motion::Element do
  element = create_event.element

  it "can fetch tag name" do
    element.name.should eq("BUTTON")
    element.tag_name.should eq("BUTTON")
  end

  it "can fetch attributes" do
    element["class"].should eq("btn btn-primary")
    element.id.should eq("motion-button")
    element.attributes.should eq({
      "data-motion" => "add",
      "class"       => "btn btn-primary",
      "id"          => "motion-button",
    })
  end

  it "can fetch data" do
    element.data["motion"].should eq("add")
  end
end

private def create_event
  Motion::Event.new(EVENT_DATA)
end
