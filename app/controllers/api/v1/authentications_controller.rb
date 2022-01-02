class Api::V1::AuthenticationsController < ApplicationController

    def signup
        user = User.new(user_params)
        
        if user.save
            token = JsonWebToken.encode(user_id: user.id)
            render json: {token: token}, status: :created
        else
            # render json: {message: user.errors.full_messages}, status: :bad_request
            raise BadRequestError(user.errors.full_messages)
        end
    end

    def signin
        user = User.find_by(email: params[:email])

        if user && user.authenticate(params[:password])
            token = JsonWebToken.encode(user_id: user.id)
            render json: {token: token}, status: :ok
        else
            # render json: {errors: ["Credentials invalide"]}, status: :bad_request
            raise InvalidCredentialsError
        end
    end

    def changepassword
        user = User.find_by(email: params[:email])
        if user && user.authenticate(params[:password])
            user.password = params[:newpassword]
            if user.save
                render json: {"Status":"OK"}, status: :ok
            end
        else
            raise InvalidCredentialsError
        end
    end

    private

    def user_params
        params.permit(:email, :password, :password_confirmation, :firstname, :lastname)
    end

end
