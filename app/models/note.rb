class UTF8Validator < ActiveModel::Validator
  def validate(record)
    if record.present?
      if record.title.to_s.force_encoding("UTF-8").valid_encoding? or record.body.to_s.force_encoding("UTF-8").valid_encoding?
        record.errors.add :base, "only UTF-8 encoding allowed"
      end
    end
  end
end

class Note < ApplicationRecord

  belongs_to :folder
  #has_many :note_tags, dependent: :destroy
  #has_many :tags, through: :note_tags
  has_many :tags, dependent: :destroy

  has_many :shared_notes, dependent: :destroy

  validates :title, presence: true

  validates :title, length: { minimum: 1, maximum: 64 }
  validates :body, length: { maximum: 1024 }

  # Not working for some unknown reason
  # validates_with UTF8Validator
end
