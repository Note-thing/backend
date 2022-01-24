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

  def user_params
    # https://stackoverflow.com/questions/5113248/devise-update-user-without-password/11676957#11676957
    #if params[:user][:password].blank? && params[:user][:password_confirmation].blank?
    #  params[:user].delete(:password)
    #  params[:user].delete(:password_confirmation)
    #end
    params.require(:user).permit(:firstname, :lastname, :email)
  end

end