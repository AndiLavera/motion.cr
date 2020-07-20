require "../spec_helper"
EVENT_DATA = JSON::Any.new("{\"type\":\"click\",\"details\":{},\"extraData\":null,\"target\":{\"tagName\":\"BUTTON\",\"value\":\"\",\"attributes\":{\"class\":\"btn btn-success\",\"data-motion\":\"add\",\"data-motion-key\":\"kROsy2xoFCkI+3PCDMINN/O9EJWiFpGXK3NOTZM=\",\"data-motion-state\":\"eyJtYXBfbW90aW9uIjp0cnVlLCJtYXBfbW90aW9uIjoiYW5kcmV3IiwibmFtZTIiOiJtZWxpbmRhIn0AVGVzdFJlbmRlcg==\"},\"formData\":null},\"currentTarget\":{\"tagName\":\"BUTTON\",\"value\":\"\",\"attributes\":{\"class\":\"btn btn-success\",\"data-motion\":\"add\",\"data-motion-key\":\"kROsy2xoFCkI+3PCDMINN/O9EJWiFpGXK3NOTZM=\",\"data-motion-state\":\"eyJtYXBfbW90aW9uIjp0cnVlLCJtYXBfbW90aW9uIjoiYW5kcmV3IiwibmFtZTIiOiJtZWxpbmRhIn0AVGVzdFJlbmRlcg==\"},\"formData\":null}}")

describe Motion::ComponentConnection do
  it "can intialize all dependencies" do
    component_connection = Motion::ComponentConnection.new(MotionRender.new)
    component_connection.render_hash.should_not be_nil
    component_connection.component.should_not be_nil
    component_connection.logger.should_not be_nil
  end

  it "can process a motion" do
    component = MotionMount.new
    component_connection = Motion::ComponentConnection.new(component)

    component.count.should eq(0)
    component_connection.process_motion("add", nil)
    component.count.should eq(1)
  end

  it "can process a motion with event" do
    component = MotionRender.new
    component_connection = Motion::ComponentConnection.new(component)

    component.motion_hit.should be_false
    component_connection.process_motion("motion", Motion::Event.from_raw(EVENT_DATA))
    component.motion_hit.should be_true
  end
end
