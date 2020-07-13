struct Crystalizer::Deserializer::Object(T, N)
  class Exception < ::Exception
  end

  @found = StaticArray(Bool, N).new false
  @object_instance : T

  def initialize
    instance = T.allocate
    GC.add_finalizer(instance) if instance.responds_to?(:finalize)
    @object_instance = instance
  end

  def self.new(type : T.class) forall T
    {% begin %}
    Deserializer::Object(T, {{T.instance_vars.size}}).new
    {% end %}
  end

  # Yields each instance variable's `Variable` metadata and it value.
  #
  # This method can be used for non self-describing formats (which does not holds keys).
  def set_each_ivar(&)
    {% for ivar in O.instance_vars %}
      {% ann = ivar.annotation(::Crystalizer::Field) %}
      {% unless ann && ann[:ignore] %}
        {% key = ((ann && ann[:key]) || ivar).id.stringify %}
        variable = Variable.new(
          type: {{ivar.type}},
          annotations: {{ann && ann.named_args}},
          nilable: {{ivar.type.nilable?}},
          has_default: {{ivar.has_default_value?}}
        )
        object.@{{ivar}} = yield(variable).as {{ivar.type}}
      {% end %}
    {% end %}
  end

  # Sets a value for an instance variable corresponding to the key.
  def set_ivar(key : String, &)
    {% begin %}
    {% i = 0 %}
    case key
    {% for ivar in T.instance_vars %}
      {% ann = ivar.annotation(::Crystalizer::Field) %}
      {% unless ann && ann[:ignore] %}
        {% key = ((ann && ann[:key]) || ivar).id.stringify %}
        when {{key}}
          raise Exception.new "duplicated key: #{key}" if @found[{{i}}]
          @found[{{i}}] = true
          variable = Variable.new(
            type: {{ivar.type}},
            annotations: {{ann && ann.named_args}},
            nilable: {{ivar.type.nilable?}},
            has_default: {{ivar.has_default_value?}}
          )
          pointerof(@object_instance.@{{ivar}}).value = yield(variable).as {{ivar.type}}
        {% end %}
        {% i = i + 1 %}
      {% end %}
      else raise Exception.new "Missing key in {{T}}: #{key}"
      end
    {% end %}
  end

  private def check_ivars
    {% begin %}
    {% i = 0 %}
    {% for ivar in T.instance_vars %}
      {% ann = ivar.annotation(::Crystalizer::Field) %}
      {% unless ann && ann[:ignore] %}
      if !@found[{{i}}]
        {% if ivar.has_default_value? %}
          @object_instance.@{{ivar}} = {{ivar.default_value}}
        {% elsif !ivar.type.nilable? %}
          raise Exception.new "Missing {{ivar}} value in {{T}}."
        {% end %}
      end
      {% end %}
      {% i = i + 1 %}
    {% end %}
    {% end %}
  end

  # Returns the deserialized object instance.
  def object_instance : T
    check_ivars
    @object_instance
  end
end
