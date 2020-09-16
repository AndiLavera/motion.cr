module Motion::Adapters
  abstract class Base
    abstract def get_component(topic : String) : Motion::Base
    abstract def mget_components(topics : Array(String)) : Array(Motion::Base)
    abstract def set_component(topic : String, component : Motion::Base) : Bool
    abstract def destroy_component(topic : String) : Bool

    abstract def get_broadcast_streams(stream_topic : String) : Array(String)
    abstract def set_broadcast_streams(topic : String, component : Motion::Base) : Bool
    abstract def destroy_broadcast_stream(topic : String, component : Motion::Base) : Bool

    abstract def get_periodic_timers(name : String) : Fiber?
    abstract def set_periodic_timers
    abstract def destroy_periodic_timers(component : Motion::Base) : Bool

    def weak_deserialize(component : String) : Motion::Base
      Motion.serializer.weak_deserialize(component)
    end
  end
end
