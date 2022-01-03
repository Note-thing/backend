class PasswordMailer < ApplicationMailer
  def new_password_email
    @user = params[:user]
    @token = params[:token]

    mail(to: @user.email, subject: "Reset your email on note thing")
  end
end
