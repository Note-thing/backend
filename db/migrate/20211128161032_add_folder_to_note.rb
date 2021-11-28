class AddFolderToNote < ActiveRecord::Migration[5.2]
  def change
    add_reference :notes, :folder, foreign_key: true
  end
end
