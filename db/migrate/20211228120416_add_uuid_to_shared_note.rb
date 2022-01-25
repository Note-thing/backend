class AddUuidToSharedNote < ActiveRecord::Migration[5.2]
  def change
    add_column :shared_notes, :uuid, :string
  end
end
