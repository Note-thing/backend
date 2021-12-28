class SharedNote < ApplicationRecord
    validates :title, :body, :uuid, presence: true

    validates :title, length: { minimum: 1, maximum: 64 }
    validates :body, length: { maximum: 1024 }
end
