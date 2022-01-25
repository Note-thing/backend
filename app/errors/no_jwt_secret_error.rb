class NoJWTSecretError < StandardError

  attr_accessor :messages

  def http_status
    403
  end

  def code
    "no_jwt_secret"
  end

  def initialize(msg = ["no jwt secret"])
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

