class AddStarlinkKitIdToStarlinkKits < ActiveRecord::Migration[7.1]
  def up
    # Add a new column for starlink_kit_id
    add_column :starlink_kits, :starlink_kit_id, :uuid

    # Copy the value from `id` to `starlink_kit_id`
    execute <<-SQL
      UPDATE starlink_kits
      SET starlink_kit_id = id
    SQL

    # Make the new column NOT NULL
    change_column_null :starlink_kits, :starlink_kit_id, false

    # Add an index for performance if needed
    add_index :starlink_kits, :starlink_kit_id, unique: true
  end

  def down
    # Remove the column if the migration is rolled back
    remove_column :starlink_kits, :starlink_kit_id
  end
end
