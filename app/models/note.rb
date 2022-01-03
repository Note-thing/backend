class Note < ApplicationRecord

  belongs_to :folder
  #has_many :note_tags, dependent: :destroy
  #has_many :tags, through: :note_tags
  has_many :tags, dependent: :destroy

  has_many :shared_notes, dependent: :destroy

  validates :title, presence: true
  validates :title, length: { minimum: 1, maximum: 64 }

end
