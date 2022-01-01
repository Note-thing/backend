
class InvalidInformationError < StandardError

  attr_accessor :message

  def http_status
    400
  end

  def code
    "invalid_information"
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

