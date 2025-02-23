# app/models/starlink_kit.rb
class StarlinkKit < ApplicationRecord
  belongs_to :starlink_user, optional: true, dependent: :destroy
  belongs_to :starlink_plan, optional: true  
  has_many :starlink_kit_renewals

  before_validation :set_default_plan, on: :create

  def self.kit_number_exists?(kit_number)
    exists?(kit_number: kit_number)
  end

  private

  def set_default_plan
    self.starlink_plan ||= StarlinkPlan.find_by(status: 'default')
  end
end
