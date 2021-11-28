class CreateSharedNotes < ActiveRecord::Migration[5.2]
  def change
    create_table :shared_notes do |t|
      t.string :title
      t.text :body

      t.timestamps
    end
  end
end
