class AddAutoRenewToStarlinkKits < ActiveRecord::Migration[7.1]
  def up
    add_column :starlink_kits, :auto_renew, :boolean, default: false, null: false
  end

  def down
    remove_column :starlink_kits, :auto_renew
  end
end
