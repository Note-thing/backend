class DropNoteTags < ActiveRecord::Migration[5.2]
  def change
    drop_table :note_tags
    add_reference :tags, :note, foreign_key: true
  end
end
