class Api::V1::AuthenticationsController < ApplicationController
    # Controller handling the sign up and sign in

    # POST /api/v1/signup
    # Register a new user, needs parameters defined in user_params
    def signup
        # Create the user and generate an email validation token
        user = User.new(user_params)
        token = user.generate_validation_token!

        # Send the token
        UserValidationMailer.with(user: user, token: token).new_user_validation_email.deliver_now

        # Save the user and display it
        if user.save
            token = JsonWebToken.encode(user_id: user.id)
            render json: {user: user.as_json(except: [
              :password_digest,
              :reset_password_token,
              :reset_password_sent_at,
              :validation_token_email,
              :validation_token_email_sent_at
            ]), token: token}, status: :created
        else
            raise BadRequestError.new(user.errors.full_messages)
        end
    end

    # POST /api/v1/signin
    # Authenticate a user, needs parameters : email, password
    def signin
        # Find the user
        user = User.find_by(email: params[:email])
        unless user
            raise InvalidCredentialsError
        end

        # Check if the email is validated
        unless user.email_validated
            raise InvalidCredentialsError.new("email not validated")
        end

        # Authenticate the user with the password
        if user.authenticate(params[:password])
            token = JsonWebToken.encode(user_id: user.id)
            render json: {user: user.as_json(except: [
              :password_digest,
              :reset_password_token,
              :reset_password_sent_at,
              :validation_token_email,
              :validation_token_email_sent_at
            ]), token: token}, status: :ok
        else
            raise InvalidCredentialsError
        end
    end



    private

    def user_params
        params.permit(:email, :password, :password_confirmation, :firstname, :lastname)
    end
end
