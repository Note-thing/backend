class UnprocessableEntityError < StandardError

  attr_accessor :messages

  def http_status
    422
  end

  def code
    "unprocessable_entity"
  end

  def initialize(msg = ["unprocessable entity"])
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


