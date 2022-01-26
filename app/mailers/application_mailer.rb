class ApplicationMailer < ActionMailer::Base

  default from: ENV["EMAIL"]
  layout 'mailer'

  # On essaie ici de détecter si on souhaite envoyer l'email dans un contexte de production ou de développement
  def get_base_url
    if Rails.env.development?
      "localhost:3001"
    else
      "note-thing.ch"
    end
  end

end
