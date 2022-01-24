class AddAccountValidatenAndValidationTokenToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :validation_token_email, :string
    add_column :users, :validation_token_email_sent_at, :datetime
    add_column :users, :email_validated, :boolean, default: false
  end
end
