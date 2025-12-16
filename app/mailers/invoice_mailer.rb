class InvoiceMailer < ApplicationMailer
  def reminder_email(invoice)
    @invoice = invoice
    @user = invoice.starlink_user
    mail(to: @user.email, subject: "Invoice Due Soon: ##{@invoice.id}")
  end
end
