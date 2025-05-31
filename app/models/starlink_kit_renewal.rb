# app/models/starlink_kit_renewal.rb
class StarlinkKitRenewal < ApplicationRecord
  belongs_to :starlink_kit
  belongs_to :starlink_user_wallet
  belongs_to :starlink_user

  include Api::V1::RenewalPdfGeneratorHelper

# Create a new renewal if needed (due date passed or no previous renewal)
  def self.create_new_renewal(wallet, kit_plan, total_due, kit_id, kit)
    # always be receipt. 
    last_renewal = kit.starlink_kit_renewals
                         .where(status: "receipt", starlink_kit_id: kit_id)
                         .order(deadline: :desc)
                         .first

    # if invoice exists. 
    last_invoice = kit.starlink_kit_renewals
                         .where(status: "invoice", starlink_kit_id: kit_id)
                         .order(deadline: :desc)
                         .first
    
    plan_price = kit_plan&.price || 0
   
    # if payment is done late (after end date) or a fresh user
    if last_renewal.nil?
      # Receipt for the current month
      kit.starlink_kit_renewals.create!(
        starlink_kit_id: kit_id,
        amount: total_due,
        deadline: Date.today,
        start_date: Date.today,
        end_date: (Date.today.next_month - 1.day),
        month: Date.today.month,
        status: "receipt",
        year: Date.today.year,
        date_of_renewal: Date.today,
        starlink_user_id: kit.starlink_user_id,
        starlink_user_wallet_id: wallet.id
      )
  
      # Invoice for next month
      next_month = Date.today.next_month
      days_remaining = (31 - Date.today.day)
      invoice_amount = days_remaining * 4000
  
      kit.starlink_kit_renewals.create!(
        starlink_kit_id: kit_id,
        amount: invoice_amount,
        deadline: (Date.today.next_month - 1.day),
        start_date: Date.today.next_month,
        end_date: next_month.end_of_month,
        status: "invoice",
        month: next_month.month,
        year: next_month.year,
        starlink_user_id: kit.starlink_user_id,
        starlink_user_wallet_id: wallet.id,
        prorated: true
      )
     elsif last_renewal&.prorated
      kit.starlink_kit_renewals.create!(
        starlink_kit_id: kit_id,
        amount: plan_price,
        start_date: last_renewal.end_date >= Date.today ? last_renewal.end_date + 1.day : Date.today,
        deadline: last_renewal.end_date >= Date.today ? last_renewal.end_date : Date.today,
        end_date: last_renewal.end_date >= Date.today ? last_renewal.end_date + 32.days : (Date.today.next_month - 1.day),
        status: "invoice",
        month: last_renewal.end_date >= Date.today ? Date.today.next_month.month : Date.today.month,
        year: last_renewal.end_date >= Date.today ? Date.today.next_month.year : Date.today.year,
        starlink_user_id: kit.starlink_user_id,
        starlink_user_wallet_id: wallet.id
      )

      if last_renewal.end_date < Date.today
        # Prorated Invoice
        next_month = Date.today.next_month
        days_remaining = (31 - Date.today.day)
        invoice_amount = days_remaining * 4000
    
        kit.starlink_kit_renewals.create!(
          starlink_kit_id: kit_id,
          amount: invoice_amount,
          deadline: (Date.today.next_month - 1.day),
          start_date: Date.today.next_month,
          end_date: next_month.end_of_month,
          status: "invoice",
          month: next_month.month,
          prorated: true,
          year: next_month.year,
          starlink_user_id: kit.starlink_user_id,
          starlink_user_wallet_id: wallet.id
        )
      end
    else
      # Invoice for next month
      next_month = last_renewal.end_date.next_month
      start_date = last_renewal.end_date.next_month.beginning_of_month # first day of next month
      end_date = start_date.end_of_month # last day of next month
  
      kit.starlink_kit_renewals.create!(
        starlink_kit_id: kit_id,
        amount: plan_price,
        start_date: start_date,
        deadline: (start_date - 1.day),
        end_date: end_date, # last day of next month
        status: "invoice",
        month: next_month.month,
        year: next_month.year,
        starlink_user_id: kit.starlink_user_id,
        starlink_user_wallet_id: wallet.id
      )
    end
  end  

  # Calculate the total amount due for unpaid renewals
  def self.total_due(wallet, kit_id, kit_plan, kit)
    unpaid_renewals_sum = kit.starlink_kit_renewals
                          .where(status: "invoice", starlink_kit_id: kit_id)
                          .sum(:amount)
  
    last_receipt = kit.starlink_kit_renewals
                          .where(status: "receipt", starlink_kit_id: kit_id)
                          .order(deadline: :desc)
                          .first

    last_invoice = kit.starlink_kit_renewals
                          .where(status: "invoice", starlink_kit_id: kit_id)
                          .order(deadline: :desc)
                          .first                     
  
    plan_price = kit_plan&.price || 0
  
    if last_receipt.nil?
      plan_price
    elsif last_invoice.nil?
      # If there is no last invoice, add the plan price
      plan_price
    elsif last_invoice&.start_date <= Date.today && last_invoice&.end_date > Date.today
      # If the last invoice's (prorated) start date is today or earlier, add the plan price.
      unpaid_renewals_sum
    elsif last_invoice&.prorated && last_invoice.end_date <= Date.today
      # If the last invoice's end date is today or before today, add the plan price
      unpaid_renewals_sum
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

    kit.update!(status: 'active')
  end  
end
