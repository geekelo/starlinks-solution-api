class Api::V1::WhatsappConfirmationsController < ApplicationController

  # Send OTP to user's WhatsApp
  def create
    normalized_number = params[:whatsapp_number].to_s.strip.gsub(/\D/, '')
  
    user = StarlinkUser.find_by(whatsapp_number: normalized_number)
  
    if user
      otp = user.generate_whatsapp_confirmation_token
      WhatsappSender.send_otp(user.whatsapp_number, otp)
      render json: { message: "OTP sent successfully via WhatsApp." }, status: :ok
    else
      render json: { error: "User not found." }, status: :not_found
    end
  end
  

  # Verify OTP and confirm WhatsApp number
  def update
    user = StarlinkUser.find_by(whatsapp_number: params[:whatsapp_number])

    if user && user.confirm_whatsapp_number(params[:otp])
      render json: { message: "WhatsApp number confirmed successfully." }, status: :ok
    else
      render json: { error: "Invalid or expired OTP." }, status: :unprocessable_entity
    end
  end
end
