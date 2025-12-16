class ConfirmationEmailMailer < ApplicationMailer
  def send_confirmation_email(user, token)
    @user = user
    @token = token
    mail(to: @user.email, subject: 'Confirm Your Password - Starlink Solutions')
  end
end
