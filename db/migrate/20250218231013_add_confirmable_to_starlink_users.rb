class AddConfirmableToStarlinkUsers < ActiveRecord::Migration[7.1]
  def up
    add_column :starlink_users, :confirmation_token, :string
    add_column :starlink_users, :confirmation_sent_at, :datetime
    add_index :starlink_users, :confirmation_token, unique: true

    # Ensure existing users are confirmed to avoid login issues
    StarlinkUser.update_all(confirmed_at: Time.current)
  end

  def down
    remove_columns :starlink_users, :confirmation_token, :confirmation_sent_at
  end
end
