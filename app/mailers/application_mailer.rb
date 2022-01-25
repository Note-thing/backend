class ApplicationMailer < ActionMailer::Base

  default from: ENV["EMAIL"]
  layout 'mailer'

  def get_base_url
    if Rails.env.development?
      "localhost:3001"
    else
      "note-thing.ch"
    end
  end


end
