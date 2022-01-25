class AddNoteToSharedNote < ActiveRecord::Migration[5.2]
  def change
    add_reference :shared_notes, :note, foreign_key: true
  end
end
