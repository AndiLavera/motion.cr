module Crystalizer::YAML
  def serialize(object)
    String.build do |str|
      serialize str, object
    end
  end

  def serialize(io : IO, object : O) forall O
    nodes_builder = ::YAML::Nodes::Builder.new
    serialize nodes_builder, object
    ::YAML.build(io) do |builder|
      nodes_builder.document.to_yaml builder
    end
  end

  def serialize(builder : ::YAML::Nodes::Builder, object : O) forall O
    builder.mapping do
      Crystalizer.each_ivar(object) do |key, value|
        serialize builder, key
        serialize builder, value
      end
    end
  end

  def serialize(builder : ::YAML::Nodes::Builder, any : Crystalizer::Any)
    serialize builder, any.raw
  end

  def serialize(builder : ::YAML::Nodes::Builder, object : ::YAML::Serializable)
    object.to_yaml builder
  end

  def serialize(builder : ::YAML::Nodes::Builder, hash : Hash)
    builder.mapping(reference: hash) do
      hash.each do |key, value|
        serialize builder, key
        serialize builder, value
      end
    end
  end

  def serialize(builder : ::YAML::Nodes::Builder, array : Array | Deque | Set | Tuple)
    builder.sequence(reference: (array.is_a?(Array) ? array : nil)) do
      array.each do |value|
        serialize builder, value
      end
    end
  end

  def serialize(builder : ::YAML::Nodes::Builder, named_tuple : NamedTuple)
    builder.mapping do
      named_tuple.each do |key, value|
        serialize builder, key
        serialize builder, value
      end
    end
  end

  def serialize(builder : ::YAML::Nodes::Builder, bool : Bool)
    builder.scalar bool
  end

  def serialize(builder : ::YAML::Nodes::Builder, object : Enum)
    builder.scalar object.value
  end

  def serialize(builder : ::YAML::Nodes::Builder, null : Nil)
    builder.scalar ""
  end

  def serialize(builder : ::YAML::Nodes::Builder, object : Number | Path | String | Symbol)
    builder.scalar object.to_s
  end

  def serialize(builder : ::YAML::Nodes::Builder, slice : Slice(UInt8))
    builder.scalar Base64.encode(slice), tag: "tag:yaml.org,2002:binary"
  end

  def serialize(builder : ::YAML::Nodes::Builder, time : Time)
    builder.scalar Time::Format::YAML_DATE.format(time)
  end
end
