class AddPasswordResetToStarlinkUsers < ActiveRecord::Migration[7.1]
  def up
    add_column :starlink_users, :reset_password_token, :string
    add_column :starlink_users, :reset_password_sent_at, :datetime
    add_index :starlink_users, :reset_password_token, unique: true
  end

  def down
    remove_index :starlink_users, :reset_password_token
    remove_column :starlink_users, :reset_password_sent_at
    remove_column :starlink_users, :reset_password_token
  end
end
