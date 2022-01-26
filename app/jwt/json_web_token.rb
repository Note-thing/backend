class JsonWebToken

    JWT_SECRET = ENV["JWT_SECRET"]
    HMAC = "HS256"

    # encodage du JWT
    # nos JWT ont une durée de vie de 24 heures
    # on hash nos JWT avec une clef secrète (JWT_SECRET), en utilisant SHA-256
    # https://datatracker.ietf.org/doc/html/rfc7519
    def self.encode(payload, exp = 24.hours.from_now)
        payload[:exp] = exp.to_i
        JWT.encode payload, JWT_SECRET, HMAC
    end

    # tentative de décodage du JWT
    def self.decode(token)
        body = JWT.decode(token, JWT_SECRET)[0]
        HashWithIndifferentAccess.new body
    rescue JWT::ExpiredSignature, JWT::VerificationError => e
        raise ExceptionHandler::ExpiredSignature, e.message
    rescue JWT::DecodeError, JWT::VerificationError => e
        raise ExceptionHandler::DecodeError, e.message
    end

end