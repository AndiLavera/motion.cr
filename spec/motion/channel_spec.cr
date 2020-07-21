require "../spec_helper"

describe Motion::Channel do
  pending("can handle a new subscriber")
  pending("can handle a new message")
  pending("can process a motion")
  pending("can handle a subscriber leaving")

  it "will raise error when client version mismatches" do
    json = {
      "identifier": {
        "state":   "",
        "version": "2.0.0a",
      },
    }

    expect_raises(Motion::Exceptions::IncompatibleClientError) do
      Motion::Channel.new.handle_joined(nil, json)
    end
  end
end
