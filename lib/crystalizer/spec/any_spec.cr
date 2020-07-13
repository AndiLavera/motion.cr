require "spec"
require "../src/any"

struct TestAny
  include Crystalizer::Any
  alias Type = Nil | Bool | Int32 | Float64 | String | Array(Crystalizer::Any) | Hash(Crystalizer::Any, Crystalizer::Any)

  getter raw : Type

  def initialize(@raw : Type)
  end

  def self.new(array : Array)
    ary = Array(Crystalizer::Any).new
    array.each do |e|
      ary << new e
    end
    new ary
  end

  def self.new(hash : Hash)
    h = Hash(Crystalizer::Any, Crystalizer::Any).new
    hash.each do |k, v|
      h[new k] = new v
    end
    new h
  end
end

describe Crystalizer::Any do
  any = TestAny.new(
    {
      "key" => "value",
      "one" => 1,
      "sub" => [true, "two", 3],
    }
  )
  it "size" do
    any.size.should eq 3
  end

  it "#[]" do
    any["key"].should eq TestAny.new "value"
    any["sub"][1].should eq TestAny.new "two"
  end

  it "#[]?" do
    any["key"]?.should eq TestAny.new "value"
    any["unknown"]?.should be_nil
    any["sub"][1]?.should eq TestAny.new "two"
  end

  it "#dig" do
    any.dig("key").should eq TestAny.new "value"
    any.dig("sub", 1).should eq TestAny.new "two"
  end

  it "#dig?" do
    any.dig?("key").should eq TestAny.new "value"
    any.dig?("unknown").should be_nil
    any.dig?("sub", 1).should eq TestAny.new "two"
  end
end
