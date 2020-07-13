require "../src/json"
require "../src/yaml"

describe Crystalizer::Any do
  it "converts back and forth to JSON/YAML" do
    yaml_doc = <<-E
    ---
    one: 1
    two: 2
    sub:
      ary:
      - one
      - 2

    E

    yaml_any = Crystalizer::YAML.parse yaml_doc

    json_doc = Crystalizer::JSON.serialize yaml_any

    json_any = Crystalizer::JSON.parse json_doc

    Crystalizer::YAML.serialize(json_any).should eq yaml_doc
  end
end
