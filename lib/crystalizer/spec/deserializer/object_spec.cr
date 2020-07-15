require "../../src/deserializer"

struct Properties
  property str : String = "Hello"
  property enabled : Bool = false
end

struct Strukt
  def initialize(@num : Int32)
  end
end

describe Crystalizer::Deserializer::Object do
  it "creates an object with default values" do
    obj = Crystalizer::Deserializer::Object.new Properties
    obj.object_instance.should eq Properties.new
  end

  it "sets an instance variable" do
    obj = Crystalizer::Deserializer::Object.new Strukt
    obj.set_ivar "num" { 123 }
    obj.object_instance.should eq Strukt.new 123
  end

  it "raises on setting a unknown key" do
    expect_raises Crystalizer::Deserializer::Object::Exception,
      message: "Unknown key in Strukt: unknown_var" do
      obj = Crystalizer::Deserializer::Object.new Strukt
      obj.set_ivar "unknown_var" { 0 }
    end
  end

  it "raises on unset instance variable" do
    expect_raises Crystalizer::Deserializer::Object::Exception,
      message: "Missing instance variable value in Strukt: num" do
      Crystalizer::Deserializer::Object.new(Strukt).object_instance
    end
  end
end
