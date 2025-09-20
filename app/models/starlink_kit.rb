# app/models/starlink_kit.rb
class StarlinkKit < ApplicationRecord
  belongs_to :starlink_user, optional: true
  belongs_to :starlink_plan, optional: true  
  has_many :starlink_kit_renewals, dependent: :destroy

  before_validation :set_default_plan, on: :create

  def self.kit_number_exists?(kit_number)
    exists?(kit_number: kit_number)
  end

  def check_and_deactivate_kit(kit)
    renewal = kit.starlink_kit_renewals
                 .where(status: "invoice", paid: false)
                 .order(deadline: :desc)
                 .first
  
    if renewal && renewal.deadline < Date.today
      kit.update!(status: 'deactivated')
    end
  end
  

  private

  def set_default_plan
    self.starlink_plan ||= StarlinkPlan.find_by(status: 'default')
  end
end
