# Set this annotation on any methods that can be invoked from the frontend.
#
# Here is a small example setting `MyComponent#add` as a motion:
# ```
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

# Set this annotation on any methods that require invocation every `x` interval.
# This annotation accepts 1 argument which is named `interval` and expects
# the type to be `Time::Span`
#
# Here is a small example setting `MyComponent#tick` as a periodic timer:
# ```
# class TickerComponent < Motion::Base
#   props ticker : Int32 = 0
#   props motion_component : Bool = true
#
#   @[Motion::PeriodicTimer(interval: 1.second)]
#   def tick
#     @ticker += 1
#   end
#
#   def render
#     div do
#       span @ticker.to_s
#     end
#   end
# end
# ```
#
# When the user hits the page containing this component, Motion will
# invoke the method assigned to `@[Motion::PeriodicTimer]` based on the
# `Time::Span` provided.
annotation Motion::PeriodicTimer; end
