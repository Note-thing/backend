class User < ApplicationRecord

    # https://stackoverflow.com/questions/2385701/regular-expression-for-first-and-last-name
    VALID_NAME_REGEX = /\A[^0-9`!@#\$%\^&*+_=]+\z/

    # devise est une gem pour l'authentification
    # https://github.com/heartcombo/devise
    has_secure_password

    validates :email,
              format: { with: URI::MailTo::EMAIL_REGEXP, message: "invalid email"},
              presence: true,
              uniqueness: true

    validates :password,
              presence: true,
              confirmation: true,
              length: { minimum: 6 },
              if: lambda {self.password.present?}

    validates :password_confirmation,
              presence: true,
              if: lambda {self.password.present?}

    validates :firstname,
              format: { with: VALID_NAME_REGEX, message: "incorrect, évitez les caractères spéciaux et les chiffres" },
              presence: true

    validates :lastname,
              format: { with: VALID_NAME_REGEX, message: "incorrect, évitez les caractères spéciaux et les chiffres" },
              presence: true

    has_many :folders, dependent: :destroy

    # attributs :
    # email, password_digest, created_at, updated_at, firstname, lastname, reset_password_token, reset_password_sent_at
    # validation_token_email, validation_token_email_sent_at, email_validated

    # quand l'utilisateur souhaite reset sont password, on génère un token que l'on stocke.
    # ce token permet de retracer retrouver l'utilisateur et de s'assurer que celui qui a reset le mdp
    # possède le bon token
    def generate_password_token!(current_password)
        token = generate_token
        self.reset_password_token = token
        self.reset_password_sent_at = Time.now.utc
        self.password_digest = current_password
        # Sans validate: false, la validation de password ne fonctionne plus.. 🤔
        save(validate: false)
        token
    end

    # génération d'un token our password
    def generate_validation_token!
        token = generate_token
        self.validation_token_email = token
        self.validation_token_email_sent_at = Time.now.utc
        save
        token
    end

    # vrai si le token de reset de password renvosé par l'utilisateur est le bon, et s'il a fait il y a moins de 4h
    def password_token_valid?(password_token)
        ((self.reset_password_sent_at + 4.hours) > Time.now.utc) && (password_token == self.reset_password_token)
    end

    # vrai si le token de validation de compte renvoyé par l'utilisateur est le bon, et s'il a fait il y a moins de 10 jours
    def email_token_valid?(email_token)
        ((self.validation_token_email_sent_at + 10.days) > Time.now.utc) && (email_token == self.validation_token_email)
    end

    # reset password, met à nil le token
    def reset_password!(password)
        self.reset_password_token = nil
        self.password = password
        self.password_confirmation = password
        save!
    end

    # vrai si l'utilisateur possède le dosseri
    def own_folder?(folder)
        folder.user.id == self.id
    end

    # vrai si l'utilisateur possède le dossier qui possède la note
    def own_note?(note)
        own_folder? note.folder
    end

    private

    # génère token, que l'on espère unique (les calculs sont bons)
    def generate_token
        SecureRandom.hex(10)
    end
end
