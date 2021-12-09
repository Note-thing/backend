class ApplicationController < ActionController::API


    def authentication
        token = get_token

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


    def logged_in_user
        token = get_token
        if token.nil?
            return nil
        end
        decode_data = JsonWebToken.decode(token)
        unless decode_data
            return nil
        end

        user_id = decode_data["user_id"] if decode_data

        unless user_id
            return nil
        end

        @user = User.find(user_id)
    end

    def get_token
        request.headers["token"]
    end

    def logged_in?
        !!logged_in_user
    end

    def authorized
        render json: { message: 'Please log in' }, status: :unauthorized unless logged_in?
    end

end
