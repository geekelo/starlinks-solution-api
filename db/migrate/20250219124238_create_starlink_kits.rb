class CreateStarlinkKits < ActiveRecord::Migration[7.1]
  def up
    create_table :starlink_kits, id: :uuid do |t|
      t.string :kit_number, null: false
      t.string :address, null: false
      t.string :nin, null: false
      t.string :company_name, null: true
      t.string :company_number, null: true
      t.string :status, default: "pending", null: false
      t.string :service_line_number, null: true
      t.references :starlink_plan, null: false, foreign_key: true, type: :uuid
      t.references :starlink_user, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end

  def down
    drop_table :starlink_kits
  end
end
