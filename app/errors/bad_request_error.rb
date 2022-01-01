class BadRequestError < StandardError

  attr_accessor :messages

  def http_status
    400
  end

  def code
    "bad_request"
  end

  def initialize(*msg)
    super
    if msg.length == 0
      self.message = ["invalid token"]
    else
      self.message = msg
    end
  end

  def to_hash
    {
      messages: message,
      code: code
    }
  end
end