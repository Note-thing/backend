
class NotFoundError < StandardError

  attr_accessor :messages

  def http_status
    404
  end

  def code
    "not_found"
  end

  def initialize(msg = ["not found"])
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

