require "./field"
require "./variable"

module Crystalizer
  extend self

  # Yields each instance variable with its key, value and `Variable` metadata.
  def each_ivar(object : O, &) forall O
    {% for ivar in O.instance_vars %}
      {% ann = ivar.annotation(::Crystalizer::Field) %}
      {% unless ann && ann[:ignore] %}
        {% key = ((ann && ann[:key]) || ivar).id.stringify %}
        yield {{key}}, object.@{{ivar}}, Variable.new(
            type: {{ivar.type}},
            annotations: {{ann && ann.named_args}},
            nilable: {{ivar.type.nilable?}},
            has_default: {{ivar.has_default_value?}}
          )
      {% end %}
    {% end %}
  end

  # Creates a new `Tuple` instance from a Tuple class.
  def create_tuple(tuple : Tuple.class, &)
    internal_create_tuple tuple do |type|
      yield type
    end
  end

  private def internal_create_tuple(tuple : T.class, &) : T forall T
    {% begin %}
      Tuple.new(
        {% for type in T.type_vars %}
         yield({{type}}).as({{type}}),
        {% end %}
      )
   {% end %}
  end
end
