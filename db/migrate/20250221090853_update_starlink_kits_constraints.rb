class UpdateStarlinkKitsConstraints < ActiveRecord::Migration[7.1]
  def up
    # Make service_line_number NOT NULL
    change_column_null :starlink_kits, :service_line_number, false
  end

  def down
    # Revert service_line_number back to allowing NULL values
    change_column_null :starlink_kits, :service_line_number, true
  end
end
