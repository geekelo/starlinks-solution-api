class AddProratedToStarlinkKitRenewals < ActiveRecord::Migration[7.1]
  def up
    add_column :starlink_kit_renewals, :prorated, :boolean, null: true, default: false
  end

  def down
    remove_column :starlink_kit_renewals, :prorated
  end
end
