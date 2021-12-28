class ApplicationController < ActionController::API


    def authentication
        token = get_token

        if token.nil?
            render json: { errors: ["Missing le token."] }, status: :forbidden
            return false
        end

        begin
            decode_data = JsonWebToken.decode(token)
        rescue ExceptionHandler::ExpiredSignature => e
            render json: { message: "Access denied!. Token has expired."}, status: :forbidden
            return

        rescue ExceptionHandler::DecodeError => e
            render json: { message: "No JWT secret. Please read the README.md."}, status: :forbidden
            return
        end

        user_id = decode_data["user_id"] if decode_data

        user = User.find(Integer(user_id))

        if user
            true
        else
            render json: { errors: ["Token incorrect."] }, status: :forbidden
        end
    end


    def logged_in_user
        token = get_token
        if token.nil?
            return nil
        end
        begin
            decode_data = JsonWebToken.decode(token)
        rescue ExceptionHandler::DecodeError => e
            render json: { message: e.inspect }, status: :forbidden
        end

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
