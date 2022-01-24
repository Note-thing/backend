class ApplicationController < ActionController::API

    def authentication
        token = get_token

        if token.nil?
            raise MissingTokenError
        end

        begin
            decode_data = JsonWebToken.decode(token)
        rescue ExceptionHandler::ExpiredSignature => e
            raise InvalidTokenError.new(e)
        rescue ExceptionHandler::DecodeError => e
            raise InvalidTokenError.new(e)
        end

        user_id = decode_data["user_id"] if decode_data

        begin
            user = User.find(Integer(user_id))
        rescue ActiveRecord::RecordNotFound => e
            raise NotFoundError.new(e.message)
        end

        if user
            true
        else
            raise InvalidTokenError
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
            raise InvalidTokenError.new(e)
        end

        unless decode_data
            return nil
        end

        user_id = decode_data["user_id"] if decode_data

        unless user_id
            return nil
        end

        begin
            user = User.find(user_id)
        rescue ActiveRecord::RecordNotFound => e
            raise NotFoundError.new(e.message)
        end

        user
    end

    def get_token
        request.headers["token"]
    end

    def logged_in?
        !!logged_in_user
    end

    def authorized
        raise MissingTokenError unless logged_in?
    end

    rescue_from BadRequestError,
                InvalidCredentialsError,
                InvalidInformationError,
                InvalidTokenError,
                MissingTokenError,
                NoJWTSecretError,
                NotFoundError,
                UnprocessableEntityError, with: :render_error_response

    def render_error_response(exception)
        render json: { messages: exception.messages , code: exception.code }, status: exception.http_status
    end

end
