class User < ApplicationRecord

    VALID_NAME_REGEX = /\A[^0-9`!@#\$%\^&*+_=]+\z/

    has_secure_password

    validates :email,
              format: { with: URI::MailTo::EMAIL_REGEXP, message: "invalid email"},
              presence: true,
              uniqueness: true

    validates :password,
              presence: true,
              confirmation: true,
              minimum: 6

    validates :password_confirmation,
              presence: true

    validates :firstname,
              format: { with: VALID_NAME_REGEX, message: "incorrect, évitez les caractères spéciaux et les chiffres" },
              presence: true

    validates :lastname,
              format: { with: VALID_NAME_REGEX, message: "incorrect, évitez les caractères spéciaux et les chiffres" },
              presence: true

    has_many :folders, dependent: :destroy

    def generate_password_token!(current_password)
        token = generate_token
        self.reset_password_token = token
        self.reset_password_sent_at = Time.now.utc
        self.password_digest = current_password
        # TODO: sans validate: false la validation de password ne fonctione plus.. 🤔
        save!(validate: false)
        token
    end

    def password_token_valid?(password_token)
        puts password_token, self.reset_password_token
        ((self.reset_password_sent_at + 4.hours) > Time.now.utc) && (password_token == self.reset_password_token)
    end

    def reset_password!(password)
        self.reset_password_token = nil
        self.password = password
        self.password_confirmation = password
        save!
    end

    private

    def generate_token
        SecureRandom.hex(10)
    end
end
