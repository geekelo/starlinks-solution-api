class RemoveStarlinkKitIdFromStarlinkKits < ActiveRecord::Migration[7.1]
  def up
    remove_column :starlink_kits, :starlink_kit_id
  end

  def down
    add_column :starlink_kits, :starlink_kit_id, :uuid
    execute <<-SQL
      UPDATE starlink_kits
      SET starlink_kit_id = id
    SQL
    change_column_null :starlink_kits, :starlink_kit_id, false
    add_index :starlink_kits, :starlink_kit_id, unique: true
  end
end
