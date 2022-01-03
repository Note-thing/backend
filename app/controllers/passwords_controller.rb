class PasswordsController < ApplicationController
  def forgot
    if params[:email].blank?
      return render json: {error: 'Email not present'}
    end

    user = User.find_by(email: email.downcase)

    if user.present? && user.confirmed_at?
      user.generate_password_token!
      # SEND EMAIL HERE
      render json: {status: 'ok'}, status: :ok
    else
      raise NotFoundError.new("email not found")
    end
  end

  def reset
    token = params[:token].to_s

    if params[:email].blank?
      raise BadRequestError.new("password token invalid")
    end

    user = User.find_by(reset_password_token: token)

    if user.present? && user.password_token_valid?
      if user.reset_password!(params[:password])
        render json: {status: 'resetted'}, status: :ok
      else
        render json: {error: user.errors.full_messages}, status: :unprocessable_entity
      end
    else
      raise NotFoundError.new("Link not valid or expired. Try generating a new link.")
    end
  end
end
