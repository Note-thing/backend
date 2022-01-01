class NoJWTSecretError < StandardError

  attr_accessor :message

  def http_status
    403
  end

  def code
    "no_jwt_secret"
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

