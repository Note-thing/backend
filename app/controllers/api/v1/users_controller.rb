class Api::V1::UsersController < ApplicationController

  # Controller responsible for updating the user informations and validating the user email


  # PATCH /api/vi/users
  # Update the user informations wiith the request parameters
  def update
    # Get current logged in user, if user is nil -> raise an error
    user = logged_in_user
    unless user
      raise BadRequestError.new("no user logged")
    end

    # If update is successful, render the updated data, else raise an error
    if user.update(user_params)
      render json: user, status: :ok
    else
      raise BadRequestError.new(user.errors.full_messages)
    end
  end


  # POST /api/v1/users/validate
  # Validates the user's email with a token passed as parameter
  def validate_email
    token = params[:token].to_s
    user = User.find_by(validation_token_email: token)

    p "token", token
    p "user", user

    # If user exists, try to validate the token
    if user.present?
      if user.email_token_valid?(token)
        user.email_validated = true
        user.save
      else
        #If the token is invalid, re-send a mail and raise an error
        token = user.generate_validation_token!
        UserValidationMailer.with(user: user, token: token).new_user_validation_email.deliver_now
        raise UnprocessableEntityError.new("Link not valid. A new email has been sent.")
      end
    else
      #If user doesn't exist raise an error
      raise UnprocessableEntityError.new("User to validate not found.")
    end
  end

  private

  # Define expected params
  def user_params
    params.require(:user).permit(:firstname, :lastname, :email)
  end

end