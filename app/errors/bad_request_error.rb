class BadRequestError < StandardError

  attr_accessor :messages

  def http_status
    400
  end

  def code
    "bad_request"
  end

  def initialize(msg = ["bad request"])
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