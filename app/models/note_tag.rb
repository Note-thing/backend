class NoteTag < ApplicationRecord

  belongs_to :note
  belongs_to :tag

  validates :tag_id, :note_id, presence: true

  # à garder, dans le cas où on souhaite refaire du many-to-many entre notes et tags

end
