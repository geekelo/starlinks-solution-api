module Api::V1::StarlinkKitActivationsHelper
  extend ActiveSupport::Concern

  # Create a new renewal if needed (due date passed or no previous renewal)
  def self.create_new_renewal(wallet, kit_plan_id, kit_id)
    last_renewal = wallet.starlink_kit_renewals
                         .where(status: "invoice", starlink_kit_id: kit_id)
                         .order(due_date: :desc)
                         .first
    
    plan_price = StarlinkPlan.find_by(id: kit_plan_id)&.price || 0

    if last_renewal.nil? || last_renewal.due_date < Date.today
  
      # Receipt for the current month
      wallet.starlink_kit_renewals.create!(
        starlink_kit_id: kit_id,
        amount: plan_price,
        due_date: Date.today,
        month: Date.today.month,
        status: "receipt",
        paid: true,
        date_of_renewal: Date.today
      )
  
      # Invoice for next month
      next_month = Date.today.next_month
      days_remaining = (next_month.end_of_month.day - Date.today.day)
      invoice_amount = days_remaining * 4000
  
      wallet.starlink_kit_renewals.create!(
        starlink_kit_id: kit_id,
        amount: invoice_amount,
        due_date: Date.today + 26.days,
        status: "invoice",
        paid: false,
        month: next_month.month,
        year: next_month.year,
      )

    else
      # Invoice for next month
      next_month = Date.today.next_month
      days_remaining = (next_month.end_of_month.day - Date.today.day)
      invoice_amount = days_remaining * 4000
  
      wallet.starlink_kit_renewals.create!(
        starlink_kit_id: kit_id,
        amount: price_plan,
        due_date: Date.today.change(day: 26)
        status: "invoice",
        paid: false,
        month: next_month.month,
        year: next_month.year,
      )
    end
  end  

  # Calculate the total amount due for unpaid renewals
  def self.total_due(wallet, kit_id, kit_plan_id)
    unpaid_renewals_sum = wallet.starlink_kit_renewals
                                .where(paid: false, starlink_kit_id: kit_id)
                                .sum(:amount)
  
    last_renewal = wallet.starlink_kit_renewals
                         .where(status: "invoice", starlink_kit_id: kit_id)
                         .order(due_date: :desc)
                         .first
  
    plan_price = StarlinkPlan.find_by(id: kit_plan_id)&.price || 0
  
    if last_renewal.nil? || last_renewal.due_date < Date.today
      unpaid_renewals_sum + plan_price
    else
      unpaid_renewals_sum
    end
  end

  # Mark all unpaid renewals as paid
  def self.mark_as_paid(wallet)
    wallet.starlink_kit_renewals.where(paid: false).update_all(
      status: "receipt",
      paid: true,
      credit_admin: true,
      date_of_renewal: Date.today
    )
  end  
end
