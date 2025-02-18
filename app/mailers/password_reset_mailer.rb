class PasswordResetMailer < ApplicationMailer
    default from: 'no-reply@yourdomain.com'
  
    def send_reset_email(user, token)
      @user = user
      @token = token
      mail(to: @user.email, subject: 'Reset Your Password')
    end
  end
  