class Api::V1::AuthenticationsController < ApplicationController

    def signup
        user = User.new(user_params)
        token = user.generate_validation_token!

        UserValidationMailer.with(user: user, token: token).new_user_validation_email.deliver_now

        if user.save
            token = JsonWebToken.encode(user_id: user.id)
            render json: {user: user.as_json(except: [:password_digest, :reset_password_token, :reset_password_sent_at]), token: token}, status: :created
        else
            raise BadRequestError.new(user.errors.full_messages)
        end
    end

    def signin
        user = User.find_by(email: params[:email])

        unless user
            raise InvalidCredentialsError
        end

        unless user.email_validated
            raise InvalidCredentialsError.new("email not validated")
        end

        if user.authenticate(params[:password])
            token = JsonWebToken.encode(user_id: user.id)
            render json: {user: user, token: token}, status: :ok
        else
            raise InvalidCredentialsError
        end
    end

    def validate_email
        token = params[:email_token].to_s

        begin
            user = User.find_by(validation_token_email: token)
        rescue ActiveRecord::RecordNotFound => e
            raise BadRequestError.new(e)
        end

        if user.present?
          if user.email_token_valid?(token)
              user.email_validated = true
              user.save
          else
              token = user.generate_validation_token!
              EmailValidationMailer.with(user: user, email: token).new_email_validation_email
              raise UnprocessableEntityError.new("Link not valid. A new email has been sent.")
          end
        else
            raise UnprocessableEntityError.new("Link not valid. A new email has been sent.")
        end

    end

    private

    def user_params
        params.permit(:email, :password, :password_confirmation, :firstname, :lastname)
    end

end
