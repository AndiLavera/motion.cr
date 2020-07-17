require "../spec_helper"

describe ViewComponent::Logger do
  context "can log at level" do
    {% for level in ["info", "warn", "error"] %}
    it {{level}} do
      ViewComponent::Logger.new.{{level.id}}("Test").should be_nil
    end
    {% end %}
  end

  it "can properly format durations" do
    ViewComponent::Logger.new.timing("Connected") do
      100.times { |i| i + 1 }
    end
  end
end
