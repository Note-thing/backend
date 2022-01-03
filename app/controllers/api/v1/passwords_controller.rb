class Api::V1::PasswordsController < ApplicationController

  before_action :authentication

  def forgot
    user = logged_in_user

    unless user
      raise NotFoundError.new("user not found")
    end

    token = user.generate_password_token!(user.password_digest)
    # SEND EMAIL HERE
    PasswordMailer.with(user: user, token: token).new_password_email.deliver_later

    render json: {status: 'mail sent'}, status: :ok
  end

  def reset
    password_token = params[:password_token].to_s

    user = logged_in_user

    if user.present? && user.password_token_valid?(password_token)
      if user.reset_password!(params[:password])
        render json: {status: 'resetted'}, status: :ok
      else
        raise UnprocessableEntityError.new(user.errors.full_messages)
      end
    else
      raise NotFoundError.new("Link not valid or expired. Try generating a new link.")
    end
  end

  def update
    user = logged_in_user

    if !params[:password].present?
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
