class UnprocessableEntityError < StandardError

  attr_accessor :message

  def http_status
    422
  end

  def code
    "unprocessable_entity"
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


