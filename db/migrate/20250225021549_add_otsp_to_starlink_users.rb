class AddOtspToStarlinkUsers < ActiveRecord::Migration[7.1]
  def up
    add_column :starlink_users, :otsp, :boolean, default: false
  end

  def down
    remove_column :starlink_users, :otsp
  end
end
