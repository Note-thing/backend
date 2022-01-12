require 'rails/commands/server/server_command'

class PasswordMailer < ApplicationMailer

  def new_password_email
    @user = params[:user]
    @token = params[:token]

    @reset_link = generate_reset_link

    mail(to: @user.email, subject: "Reset your email on note thing")
  end

  def generate_reset_link
    get_base_url + "?token=" + @token
  end

  def get_base_url
    if Rails.env.development?
      "localhost:" + Rails::Server::Options.new.parse!(ARGV)[:Port].to_s
    else
      "note-thing.ch"
    end
  end
end
