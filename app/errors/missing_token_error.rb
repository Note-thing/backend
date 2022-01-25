
class MissingTokenError < StandardError

  attr_accessor :messages

  def http_status
    403
  end

  def code
    "missing_token"
  end

  def initialize(msg = ["missing token"])
    super
    self.messages = *msg
  end

  def to_hash
    {
      messages: messages,
      code: code
    }
  end
end
