class Folder < ApplicationRecord

  belongs_to :user
  has_many :notes

  validates :title, length: { minimum: 1, maximum: 16}
  validates :title, presence: true

end
