class StarlinkKit < ApplicationRecord
  belongs_to :starlink_user, optional: true, dependent: :destroy
  has_one :starlink_plan
  
  before_validation :set_default_plan, on: :create

  def self.kit_number_exists?(kit_number)
    exists?(kit_number: kit_number)
  end

  private

  def set_default_plan
    self.starlink_plan ||= StarlinkPlan.find_by(status: "default")
  end
end
