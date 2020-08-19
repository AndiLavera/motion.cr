require "json"
require "./html_engine"
require "./logger"
require "./exceptions"
require "./motions"

# Set this annotation on any methods that can be invoked from the frontend.
#
# Here is a small example setting `MyComponent#add` as a motion:
# ```crystal
# class MyComponent < Motion::Base
#   props count : Int32 = 0
#
#   @[Motion::MapMethod]
#   def add
#     count += 1
#   end
#
#   def render
#     div do
#       span class: "count" do
#         text @count.to_s
#       end
#       button data_motion: "add" do
#         text "Add"
#       end
#     end
#   end
# end
# ```
#
# `MyComponent#render` would return:
#
# ```html
# <div>
#   <span class="count">0</span>
#   <button data-motion="add">Add</button>
# </div>
# ```
#
# When the user hits the button that `data-motion` is assigned to, a request will be sent off. The server will invoke the method provided and rerender the component. In this case, `add` will be invoked, count will increment by `1` & the html after rerendering will reflect that.
annotation Motion::MapMethod; end

abstract class Motion::Base
  include Motion::HTML::Engine
  include Motion::Motions

  @[JSON::Field(ignore: true)]
  property view : IO::Memory = IO::Memory.new
  property motion_component : Bool = false

  # def to_s(io)
  #   io << view
  # end

  # :nodoc:
  def rerender
    self.view = IO::Memory.new
    render
    view.to_s
  end

  # :nodoc:
  macro inherited
    def process_motion(motion : String, event : Motion::Event?)
      {% verbatim do %}
        {% begin %}
          case motion
          {% for method in @type.methods.select &.annotation(Motion::MapMethod) %}

            {% args = method.args %}
            {% if args[0] && !args[0].restriction.resolve == Motion::Event %}
              {% raise "MotionArgumentError: Motions can only accept `Motion::Event` type" %}
            {% end %}

            {% if args.size >= 2 %}
              {% raise "MotionArgumentError: Too many arguments for motion #{@type}##{method.name}" %}
            {% end %}

            when {{method.name.id.stringify}}
              return self.{{method.name.id}}({% if args.size == 1 %}{{"event".id}}{% end %})
          {% end %}
          end
        {% end %}
      {% end %}
    end
  end

  # :nodoc:
  macro subclasses
    {
    {% for subclass in @type.subclasses %}
      {{subclass}}: {{subclass.id}},
    {% end %}
    }
  end
end
