class NoteTag < ApplicationRecord
  validates :tag_id, :note_id, presence: true
end
