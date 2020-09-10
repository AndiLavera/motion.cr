# :nodoc:
class Motion::Message
  getter raw : JSON::Any
  @version : String?
  @state : String?
  @topic : String?
  @command : String?
  @name : String?
  @data : String?
  @identifier : String?

  def initialize(@raw : JSON::Any); end

  def version
    @version ||= raw["identifier"]["version"].as_s
  end

  def state
    @state ||= raw["identifier"]["state"].as_s
  end

  def topic
    @topic ||= raw["topic"].to_s
  end

  def payload
    raw["payload"]
  end

  def identifier
    @identifier ||= payload["identifier"]?.to_s
  end

  def data
    @data ||= payload["data"]?.to_s
  end

  def command
    @command ||= payload["command"]?.to_s
  end

  def name
    @name ||= payload["data"]["name"].as_s
  end

  def payload_data
    [identifier, data, command]
  end

  def event
    Motion::Event.new(payload["data"]["event"])
  end
end
