struct Crystalizer::YAML::Any
  include Crystalizer::Any
  alias Type = Nil | Bool | Int64 | Float64 | String | Time | Bytes | Array(Crystalizer::Any) | Hash(Crystalizer::Any, Crystalizer::Any)

  getter raw : Type

  def initialize(@raw : Type)
  end

  def self.new(ctx : ::YAML::ParseContext, node : ::YAML::Nodes::Node)
    anchors = Hash(String, Any).new
    convert(node, anchors)
  end

  private def self.convert(node : ::YAML::Nodes::Node, anchors : Hash(String, Any))
    case node
    when ::YAML::Nodes::Scalar
      new ::YAML::Schema::Core.parse_scalar(node.value)
    when ::YAML::Nodes::Sequence
      ary = Array(Crystalizer::Any).new

      if anchor = node.anchor
        anchors[anchor] = new ary
      end

      node.each do |value|
        ary << convert(value, anchors)
      end

      new ary
    when ::YAML::Nodes::Mapping
      hash = Hash(Crystalizer::Any, Crystalizer::Any).new

      if anchor = node.anchor
        anchors[anchor] = new hash
      end

      node.each do |key, value|
        hash[convert(key, anchors)] = convert(value, anchors)
      end

      new hash
    when ::YAML::Nodes::Alias
      anchors[node.anchor]
    else
      raise Exception.new "Unknown node: #{node.class}"
    end
  end
end
