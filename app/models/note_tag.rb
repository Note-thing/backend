class NoteTag < ApplicationRecord

  belongs_to :note
  belongs_to :tag

  validates :tag_id, :note_id, presence: true

end
