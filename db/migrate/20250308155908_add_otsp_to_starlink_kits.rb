class AddOtspToStarlinkKits < ActiveRecord::Migration[7.1]
  def up
    add_column :starlink_kits, :otsp, :boolean, default: false

    # Ensure all existing records have otsp set to true
    StarlinkKit.update_all(otsp: true)
  end

  def down
    remove_column :starlink_kits, :otsp
  end
end
