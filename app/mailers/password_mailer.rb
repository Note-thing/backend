class PasswordMailer < ApplicationMailer

  layout false

  # envoie de mail de reset de password
  # cherche par convention le template du même nom -> utilise donc views/password_mailer/new_password_email.html.erb
  def new_password_email
    @user = params[:user]
    @token = params[:token]

    @link = generate_reset_link

    mail(to: @user.email, subject: "Changement de mot de passe sur note-thing.ch")
  end

  def generate_reset_link
    get_base_url + "/change_password"+ "?token=" + @token
  end

end
