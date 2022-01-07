class Api::V1::AuthenticationsController < ApplicationController

    def signup
        user = User.new(user_params)
        
        if user.save
            token = JsonWebToken.encode(user_id: user.id)
            render json: {user: user.as_json(except: [:password_digest, :reset_password_token, :reset_password_sent_at]), token: token}, status: :created
        else
            raise BadRequestError.new(user.errors.full_messages)
        end
    end

    def signin
        user = User.find_by(email: params[:email])

        if user && user.authenticate(params[:password])
            token = JsonWebToken.encode(user_id: user.id)
            render json: {user: user, token: token}, status: :ok
        else
            raise InvalidCredentialsError
        end
    end

    private

    def user_params
        params.permit(:email, :password, :password_confirmation, :firstname, :lastname)
    end

end
