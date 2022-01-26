class UserValidationMailer < ApplicationMailer

  layout false

  # envoie de mail de reset de password
  # cherche par convention le template du même nom -> utilise donc views/user_validation_mailer/new_user_validation_email.html.erb
  def new_user_validation_email
    @user = params[:user]
    @token = params[:token]

    @link = generate_validate_link

    mail(to: @user.email,
         subject: "Vérifiez votre compte sur note-thing.ch",
         template_path: 'user_validation_mailer',
         template_name: 'new_user_validation_email')
  end

  def generate_validate_link
    get_base_url + "/validate_account"+ "?token=" + @token
  end

end
