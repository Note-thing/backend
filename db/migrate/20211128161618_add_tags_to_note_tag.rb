class AddTagsToNoteTag < ActiveRecord::Migration[5.2]
  def change
    add_reference :note_tags, :tag, foreign_key: true
    add_reference :note_tags, :note, foreign_key: true

  end
end
