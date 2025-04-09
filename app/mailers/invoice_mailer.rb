class InvoiceMailer < ApplicationMailer
  default from: 'notifications@example.com' # Change this to your actual email

  def reminder_email(invoice)
    @invoice = invoice
    @user = invoice.starlink_user
    mail(to: @user.email, subject: "Invoice Due Soon: ##{@invoice.id}")
  end
end
