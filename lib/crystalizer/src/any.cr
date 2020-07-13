module Crystalizer::Any
  # Returns the raw underlying value, a `T`.
  abstract def raw

  # Casts the underlying value to `T`.
  def to(type : T.class) : T forall T
    to?(type) || raise Exception.new "Expected #{T}, not #{@raw.class}"
  end

  # Casts the underlying value to `T`, or return nil if not possible.
  def to?(type : T.class) forall T
    @raw.as? T
  end

  def size : Int
    cast_to_hash_or_indexable.size
  end

  private def cast_to_hash_or_indexable?(object = @raw)
    case object
    when Hash, Indexable then object
    else                      nil
    end
  end

  private def cast_to_hash_or_indexable(object = @raw)
    cast_to_hash_or_indexable?(object) || raise Exception.new "Expected Hash or Indexable, not #{@raw.class}"
  end

  # Assumes the underlying value is an `Indexable` or a `Hash`, and returns the element
  # at the given index.
  #
  # Raises if the underlying value is not an `Indexable` or a `Hash`.
  def [](index : Int)
    cast_to_hash_or_indexable[index]
  end

  # Assumes the underlying value is an `Indexable` and returns the element
  # at the given index, or `nil` if out of bounds.
  #
  # Raises if the underlying value is not an `Indexable`.
  def []?(index : Int)
    cast_to_hash_or_indexable[index]?
  end

  # Assumes the underlying value is a `Hash` and returns the element
  # with the given key.
  #
  # Raises if the underlying value is not a `Hash`.
  def [](key)
    self[key]? || raise Exception.new "Key not found: #{key}"
  end

  # Assumes the underlying value is a `Hash` and returns the element
  # with the given key, or `nil` if the key is not present.
  #
  # Raises if the underlying value is not a `Hash`.
  def []?(key)
    h = to(Hash)
    if typeof(h.values[0]) == Crystalizer::Any
      if key_value = h.find &.first.raw.==(key)
        key_value.last
      end
    else
      h[key]?
    end
  end

  # Traverses the depth of a structure and returns the value.
  # Returns `nil` if not found.
  def dig?(key, *subkeys)
    self[key]?.try &.dig?(*subkeys)
  end

  # :nodoc:
  def dig?(key_or_index)
    self[key_or_index]? if cast_to_hash_or_indexable?
  end

  # Traverses the depth of a structure and returns the value, otherwise raises.
  def dig(key_or_index, *subkeys)
    self[key_or_index].dig(*subkeys)
  end

  # :nodoc:
  def dig(key_or_index)
    self[key_or_index]
  end

  # :nodoc:
  def inspect(io : IO) : Nil
    @raw.inspect(io)
  end

  # :nodoc:
  def to_s(io : IO) : Nil
    @raw.to_s(io)
  end

  # :nodoc:
  def pretty_print(pp)
    @raw.pretty_print(pp)
  end

  # Returns `true` if both `self` and *other*'s raw object are equal.
  def ==(other : Any) : Bool
    raw == other.raw
  end

  # See `Object#hash(hasher)`
  def_hash raw

  # Returns a new `Any` instance with the `raw` value `dup`ed.
  def dup : Any
    new @raw.dup
  end

  # Returns a new `Any` instance with the `raw` value `clone`ed.
  def clone : Any
    new @raw.clone
  end
end
