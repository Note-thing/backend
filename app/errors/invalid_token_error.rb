
class InvalidTokenError < StandardError

  attr_accessor :messages

  def http_status
    403
  end

  def code
    "invalid_token"
  end

  def initialize(msg = ["invalid token"])
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
