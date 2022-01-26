class Folder < ApplicationRecord

  belongs_to :user
  has_many :notes, dependent: :destroy

  validates :title, length: { minimum: 1, maximum: 16}
  validates :title, presence: true

  # attributs :
  # title, created_at, updated_at, user_id

end
