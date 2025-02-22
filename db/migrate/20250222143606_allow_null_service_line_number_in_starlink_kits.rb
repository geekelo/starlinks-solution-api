class AllowNullServiceLineNumberInStarlinkKits < ActiveRecord::Migration[7.1]
  def up
    change_column_null :starlink_kits, :service_line_number, true
  end

  def down
    change_column_null :starlink_kits, :service_line_number, false
  end
end
