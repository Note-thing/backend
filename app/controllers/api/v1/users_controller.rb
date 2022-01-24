class Api::V1::UsersController < ApplicationController

  # PATCH /api/vi/users
  def update
    user = logged_in_user
    unless user
      raise BadRequestError.new("no user logged")
    end

    if user.update(user_params)
      render json: user, status: :ok
    else
      raise BadRequestError.new(user.errors.full_messages)
    end
  end


  def validate_email
    token = params[:token].to_s

    user = User.find_by(validation_token_email: token)

    p "token", token
    p "user", user

    if user.present?
      if user.email_token_valid?(token)
        user.email_validated = true
        user.save
      else
        token = user.generate_validation_token!
        UserValidationMailer.with(user: user, token: token).new_user_validation_email.deliver_now
        raise UnprocessableEntityError.new("Link not valid. A new email has been sent.")
      end
    else
      raise UnprocessableEntityError.new("User to validate not found.")
    end
  end

  private

  def user_params
    params.require(:user).permit(:firstname, :lastname, :email)
  end

end