
class InvalidInformationError < StandardError

  attr_accessor :messages

  def http_status
    400
  end

  def code
    "invalid_information"
  end

  def initialize(msg = ["invalid information"])
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

