class Api::V1::AuthenticationsController < ApplicationController

    def signup
        user = User.new(login_params)
        
        if user.save
            token = JsonWebToken.encode(user_id: user.id)
            render json: {token: token}, status: :created
        else
            render json: {message: user.errors.full_messages}, status: :bad_request
        end
    end

    def login
        user = User.find_by(email: params[:email])

        if user && user.password == params[:password]
            token = JsonWebToken.encode(user_id: user.id)
            render json: {token: token}, status: :ok
        else
            render json: {message: "credentials invalides"}
        end
    end

    private

    def login_params
        params.permit(:email, :password)
    end

end
