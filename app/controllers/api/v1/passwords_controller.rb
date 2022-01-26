class Api::V1::PasswordsController < ApplicationController

  # Controller responsible for password update, reset and recovery

  # POST /api/v1/password/forgot
  # Handles the case if the user forgot it's password, needs parameters : email
  def forgot
    # Check if the email is valid
    if params[:email].blank?
      raise BadRequestError.new("email not present")
    end

    # Find user with it's email
    email = params[:email]
    user = User.find_by(email: email.downcase)

    # Case if the email doesn't have a user
    unless user
      raise NotFoundError.new("user not found")
    end

    # Generate a new token
    token = user.generate_password_token!(user.password_digest)

    # Send an email to the user with the password
    PasswordMailer.with(user: user, token: token).new_password_email.deliver_later
    render json: {status: 'mail sent'}, status: :ok
  end

  # POST /api/v1/password/reset
  # Handles the case if a user forgot his password clicked the recovery link sent by email, needs parameters : password_token, password
  def reset

    # Find the user corresponding to the password recovery token
    token = params[:password_token].to_s
    user = User.find_by(reset_password_token: token)

    # Reset the password if the token and the user are valid
    if user.present? && user.password_token_valid?(token)
      if user.reset_password!(params[:password])
        render json: {status: 'resetted'}, status: :ok
      else
        raise UnprocessableEntityError.new(user.errors.full_messages)
      end
    else
      raise BadRequestError.new("Link not valid or expired. Try generating a new link.")
    end
  end

  # PATCH/PUT unused
  # Updates the user's password, needs parameters : password
  def update
    user = logged_in_user

    unless params[:password].present?
      raise UnprocessableEntityError.new("password not present")
    end

    if user.reset_password(params[:password])
      render json: {status: 'ok'}, status: :ok
    else
      #render json: {errors: current_user.errors.full_messages}, status: :unprocessable_entity
      raise UnprocessableEntityError.new(current_user.errors.full_messages)
    end
  end
end
