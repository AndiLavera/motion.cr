struct Crystalizer::JSON::Any
  include Crystalizer::Any
  alias Type = Nil | Bool | Int64 | Float64 | String | Array(Crystalizer::Any) | Hash(String, Crystalizer::Any)

  getter raw : Type

  def initialize(@raw : Type)
  end

  def self.new(pull : ::JSON::PullParser)
    new case pull.kind
    when .null?
      pull.read_null
    when .bool?
      pull.read_bool
    when .int?
      pull.read_int
    when .float?
      pull.read_float
    when .string?
      pull.read_string
    when .begin_array?
      ary = Array(Crystalizer::Any).new
      pull.read_array do
        ary << new pull
      end
      ary
    when .begin_object?
      hash = Hash(String, Crystalizer::Any).new
      pull.read_object do |key|
        hash[key] = new pull
      end
      hash
    else
      raise Exception.new "Unknown pull kind: #{pull.kind}"
    end
  end
end
