class Tag < ApplicationRecord

  has_many :notes, through: :notes_tags

  validates :title, presence: true
  validates :title, length: { minimum: 1, maximum: 32 }

end
