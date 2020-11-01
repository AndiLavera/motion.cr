require "../spec_helper"

describe Motion::Configuration do
  after_each do
    Motion.reset_config
  end

  it "can be initialized with a block" do
    Motion.configure do |config|
      config.render_component_comments = false
      config.adapter = :redis
    end

    Motion.config.render_component_comments.should be_false
    Motion.config.finalized.should be_true
    Motion.config.adapter.should eq(:redis)
  end

  it "raises error when configured twice" do
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
