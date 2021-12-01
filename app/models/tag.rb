class Tag < ApplicationRecord
  validates :title, presence: true
  validates :title, length: { minimum: 1, maximum: 32 }
end
