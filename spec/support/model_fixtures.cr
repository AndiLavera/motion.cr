class TestRender < Motion::Base
  def render
    render_complicated_html
  end

  private def render_complicated_html
    header({class: "header"}) do
      style "body { font-size: 2em; }"
      text "my text"
      h1 "h1"
      br
      div class: "empty-contents" do
        br({class: "br"})
        br class: "br"
        img({src: "src"})
        h2 "A bit smaller", {class: "peculiar"}
      end
      h6 class: "h6" do
        small "super tiny", class: "so-small"
        span "wow"
      end
    end
  end
end

class UnsafePage < Motion::Base
  def render
    text "<script>not safe</span>"
  end
end

abstract class MainLayout < Motion::Base
  def render
    title page_title

    body do
      inner
    end
  end

  abstract def inner
  abstract def page_title
end

class InnerPage < MainLayout
  props foo : String

  def inner
    text "Inner text"
    text @foo
  end

  def page_title
    "A great title"
  end
end

class LessNeedyDefaultsPage < MainLayout
  props a_string : String = "string default"
  props bool : Bool = false
  props nil_default : String? = nil
  props inferred_nil_default : String?
  props inferred_nil_default2 : String | Nil

  def inner
    div @a_string
    div("bool default") if @bool == false
    div("nil default") if @nil_default.nil?
    div("inferred nil default") if @inferred_nil_default.nil?
    div("inferred nil default 2") if @inferred_nil_default2.nil?
  end

  def page_title
    "Boolean Default"
  end
end

class MotionRender < Motion::Base
  props test_bool : Bool = false
  props motion_hit : Bool = false

  @[Motion::MapMethod]
  def motion
    @motion_hit = true
  end

  @[Motion::MapMethod]
  def add
    @motion_hit = true
  end

  def render
    m MotionMount
  end
end

class MotionMount < Motion::Base
  props motion_component : Bool = true
  props test_prop : String = "Test Prop"
  props count : Int32 = 0

  @[Motion::MapMethod]
  def add
    @count += 1
  end

  def render
    div do
      div data_motion: "add" do
        h2 @count.to_s
      end
    end
  end
end

class UnsafeMultipleRootsRender < Motion::Base
  property hello : String = "Name"

  def render
    m UnsafeMultipleRootsMount
    view.to_s
  end
end

class UnsafeMultipleRootsMount < Motion::Base
  property motion_component : Bool = true

  def render
    div do
      div data_motion: "add" do
        h2 "Subheading"
      end
    end
    div do
      h1 "hi"
    end
  end
end

class TickerComponent < Motion::Base
  props count : Int32 = 0
  props motion_component : Bool = true

  @[Motion::PeriodicTimer(interval: 1.second)]
  def tick
    @count += 1
  end

  def render
    div do
      span @count.to_s
    end
  end
end

class BroadcastComponent < Motion::Base
  props count : Int32 = 0
  props motion_component : Bool = true

  stream_from "todos:created", "add"

  def add
    @count += 1
  end

  def render
    div do
      span @count.to_s
    end
  end
end
