class AddStarlinkKitIdToStarlinkPlans < ActiveRecord::Migration[7.1]
  def up
    add_column :starlink_plans, :starlink_kit_id, :uuid
    add_index :starlink_plans, :starlink_kit_id, unique: true
  end

  def down
    remove_index :starlink_plans, :starlink_kit_id
    remove_column :starlink_plans, :starlink_kit_id
  end
end
