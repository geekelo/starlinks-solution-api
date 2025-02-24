class Api::V1::WhatsappConfirmationsController < ApplicationController
  before_action :authenticate_token!
  
  # Send OTP to user's WhatsApp
  def create
    user = current_user

    if user
      otp = user.generate_whatsapp_confirmation_token
      message_sid = WhatsappSender.send_otp(user.whatsapp_number, otp)

      if message_sid
        render json: { message: 'OTP sent successfully via WhatsApp.', sid: message_sid }, status: :ok
      else
        render json: { error: 'Failed to send OTP.' }, status: :unprocessable_entity
      end
    else
      render json: { error: 'User not found.' }, status: :not_found
    end
  end

  # Verify OTP and confirm WhatsApp number
  def confirm_user_whatsapp
    unless current_user.whatsapp_confirmation_token == params[:code]
      return render json: { error: "Invalid confirmation token" }, status: :unauthorized
    end

    if current_user&.confirm_whatsapp_number(params[:code])
      render json: { message: 'WhatsApp number confirmed successfully.' }, status: :ok
    else
      render json: { error: 'Invalid or expired OTP.' }, status: :unprocessable_entity
    end
  end
end
