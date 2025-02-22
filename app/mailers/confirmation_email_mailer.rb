class ConfirmationEmailMailer < ApplicationMailer
  default from: 'no-reply@yourdomain.com'

  def send_confirmation_email(user, token)
    @user = user
    @token = token
    mail(to: @user.email, subject: 'Confirm Your Password')
  end
end
