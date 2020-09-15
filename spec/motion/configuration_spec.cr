require "../spec_helper"

describe Motion::Configuration do
  it "can be initialized with a block" do
    Motion.config.finalized = false

    Motion.configure do |config|
      config.render_component_comments = false
      config.adapter = :redis
    end

    Motion.config.render_component_comments.should be_false
    Motion.config.finalized.should be_true
    Motion.config.adapter.should eq(:redis)
  end

  it "raises error when configured twice" do
    Motion.config.finalized = false

    Motion.configure do |config|
      config.render_component_comments = false
    end

    expect_raises(Motion::Exceptions::AlreadyConfiguredError) do
      Motion.configure do |config|
        config.render_component_comments = false
      end
    end
  end
end
