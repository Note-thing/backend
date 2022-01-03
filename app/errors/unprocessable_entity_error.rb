class UnprocessableEntityError < StandardError

  attr_accessor :memessagesssage

  def http_status
    422
  end

  def code
    "unprocessable_entity"
  end

  def initialize(*msg)
    super
    if msg.length == 0
      self.messages = ["invalid token"]
    else
      self.messages = msg
    end
  end

  def to_hash
    {
      messages: messages,
      code: code
    }
  end
end


