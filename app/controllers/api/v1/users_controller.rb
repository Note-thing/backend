class Api::V1::UsersController < ApplicationController

  # PUT/PATCH /api/vi/users
  def update
    user = logged_in_user
    unless user
      raise BadRequestError.new("no user logged")
    end

    if user.update user_params
      render json: user, status: :ok
    else
      raise BadRequestError.new(user.errors.full_messages)
    end


  end

  def user_params
    params.require(:user).permit(:firstname, :lastname, :email)
  end

end
