class RemoveOtspFromStarlinkUsers < ActiveRecord::Migration[7.1]
  def up
    remove_column :starlink_users, :otsp, if_exists: true
  end

  def down
    add_column :starlink_users, :otsp, :boolean, default: false
  end
end
