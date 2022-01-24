class PasswordMailer < ApplicationMailer

  def new_password_email
    @user = params[:user]
    @token = params[:token]

    @link = generate_reset_link

    mail(to: @user.email, subject: "Changement de mot de passe sur note-thing.ch")
  end

  def generate_reset_link
    get_base_url + "?token=" + @token
  end

end
