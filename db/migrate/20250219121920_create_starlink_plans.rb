class CreateStarlinkPlans < ActiveRecord::Migration[7.1]
  def up
    create_table :starlink_plans, id: :uuid do |t|
      t.string :name, null: false
      t.decimal :price, precision: 10, scale: 2, null: false
      t.string :status, default: "optional", null: false

      t.timestamps
    end
  end

  def down
    drop_table :starlink_plans
  end
end
