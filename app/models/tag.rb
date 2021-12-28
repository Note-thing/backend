class Tag < ApplicationRecord

  has_many :note_tags, dependent: :destroy
  has_many :notes, through: :note_tags

  validates :title, presence: true
  validates :title, length: { minimum: 1, maximum: 32 }

end
