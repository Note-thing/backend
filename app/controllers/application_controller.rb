class ApplicationController < ActionController::API

    JWT_SECRET = ENV["JWE_SECRET"]
    HMAC = "HS256"

    def authentication
        decode_data = JsonWebToken.decode(request.headers["token"])
        user_data = decode_data[0]["user_id"] unless !decode_data
        user = User.find(user_data&.id)

        if user
            return true
        else
            render json: { message: "Login incorrect." }
        end
    end



end
