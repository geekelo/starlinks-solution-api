class AddStartAndEndDateToStarlinkKitRenewals < ActiveRecord::Migration[7.1]
  def up
    change_table :starlink_kit_renewals, bulk: true do |t|
      t.date :start_date, null: false
      t.date :end_date, null: false
    end
  end

  def down
    change_table :starlink_kit_renewals, bulk: true do |t|
      t.remove :start_date, :end_date
    end
  end
end
