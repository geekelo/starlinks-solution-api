# app/models/starlink_kit.rb
class StarlinkKit < ApplicationRecord
  belongs_to :starlink_user, optional: true, dependent: :destroy
  has_one :starlink_plan

  before_validation :set_default_plan, on: :create

  private

  def set_default_plan
    self.starlink_plan ||= StarlinkPlan.find_by(status: 'default')
  end
end
