class AddIsMirrorToNote < ActiveRecord::Migration[5.2]
  def change
    add_column :notes, :has_mirror, :boolean, default: false
  end
end
