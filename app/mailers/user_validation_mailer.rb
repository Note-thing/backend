class UserValidationMailer < ApplicationMailer

  layout false

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
    get_base_url + "?token=" + @token
  end

end
