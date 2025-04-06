class Api::V1::Admin::InvoiceRemindersController < ApplicationController
  before_action :authenticate_token!
  
  def send_reminders
    days_before_due = [14, 10, 7, 5, 4, 3, 2, 1]
    today = Date.today

    invoices = StarlinkKitRenewal.where(status: "invoice")
    .where(deadline: days_before_due.map { |d| today + d })

    invoices.each do |invoice|
      InvoiceMailer.reminder_email(invoice).deliver_now
    end

    render json: { message: "Invoice reminders sent." }, status: :ok
  end
end
