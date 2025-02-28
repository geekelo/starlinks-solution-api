# app/models/starlink_kit_renewal.rb
class StarlinkKitRenewal < ApplicationRecord
  belongs_to :starlink_kit
  belongs_to :starlink_user_wallet
  belongs_to :starlink_user

  include Api::V1::RenewalPdfGeneratorHelper
  include Api::V1::StarlinkKitRenewalsHelper
  include Api::V1::StarlinkKitActivationsHelper

# Create a new renewal if needed (due date passed or no previous renewal)
  def self.create_new_renewal(wallet, kit_plan_id, total_due, kit_id, kit)
    last_renewal = kit.starlink_kit_renewals
                         .where(status: "invoice", starlink_kit_id: kit_id)
                         .order(deadline: :desc)
                         .first
    
    plan_price = StarlinkPlan.find_by(id: kit_plan_id)&.price || 0

    if last_renewal.nil? || last_renewal.deadline < Date.today
  
      # Receipt for the current month
      kit.starlink_kit_renewals.create!(
        starlink_kit_id: kit_id,
        amount: total_due,
        deadline: Date.today,
        month: Date.today.month,
        status: "receipt",
        date_of_renewal: Date.today,
        starlink_user_id: kit.starlink_user_id,
        starlink_user_wallet_id: wallet.id
      )
  
      # Invoice for next month
      next_month = Date.today.next_month
      days_remaining = (next_month.end_of_month.day - Date.today.day)
      invoice_amount = days_remaining * 4000
  
      kit.starlink_kit_renewals.create!(
        starlink_kit_id: kit_id,
        amount: invoice_amount,
        deadline: Date.today + 26.days,
        status: "invoice",
        month: next_month.month,
        year: next_month.year,
        starlink_user_id: kit.starlink_user_id,
        starlink_user_wallet_id: wallet.id
      )

    else
      # Invoice for next month
      next_month = Date.today.next_month
      days_remaining = (next_month.end_of_month.day - Date.today.day)
      invoice_amount = days_remaining * 4000
  
      kit.starlink_kit_renewals.create!(
        starlink_kit_id: kit_id,
        amount: price_plan,
        deadline: Date.today.change(day: 26),
        status: "invoice",
        month: next_month.month,
        year: next_month.year,
        starlink_user_id: kit.starlink_user_id,
        starlink_user_wallet_id: wallet.id
      )
    end
  end  

  # Calculate the total amount due for unpaid renewals
  def self.total_due(wallet, kit_id, kit_plan_id, kit)
    unpaid_renewals_sum = kit.starlink_kit_renewals
                                .where(status: "invoice", starlink_kit_id: kit_id)
                                .sum(:amount)
  
    last_renewal = kit.starlink_kit_renewals
                         .where(status: "receipt", starlink_kit_id: kit_id)
                         .order(deadline: :desc)
                         .first
  
    plan_price = StarlinkPlan.find_by(id: kit_plan_id)&.price || 0
  
    if last_renewal.nil? || last_renewal.deadline < Date.today
      unpaid_renewals_sum + plan_price
    else
      unpaid_renewals_sum
    end
  end

  # Mark all unpaid renewals as paid
  def self.mark_as_paid(wallet, kit)
    kit.starlink_kit_renewals.where(status: "invoice").update_all(
      status: "receipt",
      credit_admin: true,
      date_of_renewal: Date.today
    )
  end  
end
