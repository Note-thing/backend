class ApplicationController < ActionController::API

    def authentication
        token = request.headers["token"]

        if token.nil?
            render json: { message: "Missing le token." }, status: :forbidden
            return false
        end

        decode_data = JsonWebToken.decode(token)

        user_id = decode_data["user_id"] if decode_data

        user = User.find(Integer(user_id))

        if user
            return true
        else
            render json: { message: "Token incorrect." }, status: :forbidden
        end
    end

end
