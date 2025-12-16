class PasswordResetMailer < ApplicationMailer
  def send_reset_email(user, token)
    @user = user
    @token = token
    mail(
      to: @user.email,
      subject: 'Reset Your Password - Starlink Solutions'
    )
  end
end
