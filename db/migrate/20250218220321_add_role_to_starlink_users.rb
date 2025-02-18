class AddRoleToStarlinkUsers < ActiveRecord::Migration[7.1]
  def up
    add_column :starlink_users, :role, :string, default: "user", null: false
  end

  def down
    remove_column :starlink_users, :role
  end
end
