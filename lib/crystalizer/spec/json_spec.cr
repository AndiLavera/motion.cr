require "spec"
require "../src/json"
require "./format_helper"

private def assert_json_serialization(object : T, string : String, line = __LINE__) forall T
  it "serializes", line: line do
    Crystalizer::JSON.serialize(object, indent: "").should eq string
  end

  it "deserializes", line: line do
    Crystalizer::JSON.deserialize(string, to: T).should eq object
  end
end

describe Crystalizer::JSON do
  describe "struct" do
    point = Point.new 1, "a"
    json_point = %({"x":1,"Y":"a"})

    assert_json_serialization point, json_point
  end

  describe "class" do
    obj = Obj.new ["a", "b"]
    json_obj = %({"ary":["a","b"]})

    assert_json_serialization obj, json_obj
  end

  describe Crystalizer::JSON::Any do
    json = %({"ary":["a",1]})
    any = Crystalizer::JSON.parse json
    assert_json_serialization any, json
  end

  describe Hash do
    assert_json_serialization({"a" => 123}, %({"a":123}))
  end

  describe Array do
    assert_json_serialization(["a", 2], %(["a",2]))
  end

  describe Tuple do
    assert_json_serialization({"a", 2}, %(["a",2]))
  end

  describe Enum do
    assert_json_serialization(Enu::A, "0")
  end

  describe NamedTuple do
    assert_json_serialization({a: "A", b: 1}, %({"a":"A","b":1}))
  end

  describe Bool do
    assert_json_serialization(true, "true")
  end

  describe Float do
    assert_json_serialization(1.5_f32, "1.5")
    assert_json_serialization(1.5_f64, "1.5")
  end

  describe Int do
    assert_json_serialization(1, "1")
    assert_json_serialization(1_u64, "1")
  end

  describe String do
    assert_json_serialization("a", %("a"))
  end

  describe Symbol do
    it "serializes" do
      Crystalizer::JSON.serialize(:a, indent: "").should eq %("a")
    end
  end

  describe Nil do
    assert_json_serialization(nil, "null")
  end

  describe Time do
    assert_json_serialization Time.utc(2020, 1, 2, 3), %("2020-01-02T03:00:00Z")
  end
end
