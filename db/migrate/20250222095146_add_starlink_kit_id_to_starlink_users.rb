class AddStarlinkKitIdToStarlinkUsers < ActiveRecord::Migration[7.1]
  def up
    add_reference :starlink_users, :starlink_kit, type: :uuid, foreign_key: true
  end

  def down
    remove_reference :starlink_users, :starlink_kit, foreign_key: true
  end
end
