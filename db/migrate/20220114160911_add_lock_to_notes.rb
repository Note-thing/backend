class AddLockToNotes < ActiveRecord::Migration[5.2]
  def change
    add_column :notes,  :reference_note, :integer
    add_column :notes, :read_only, :boolean
    add_column :notes, :lock, :boolean

    # read_only, :mirror, :copy_content
    add_column :shared_notes, :sharing_type, :string
  end
end