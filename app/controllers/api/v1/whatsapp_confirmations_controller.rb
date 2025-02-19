class Api::V1::WhatsappConfirmationsController < ApplicationController
  before_action :find_user, only: [:create, :update]

  # Send OTP to user's WhatsApp
  def create
    if @user
      otp = @user.generate_whatsapp_confirmation_token
      WhatsappSender.send_otp(@user.whatsapp_number, otp) # Replace with actual WhatsApp API call
      render json: { message: "OTP sent successfully via WhatsApp." }, status: :ok
    else
      render json: { error: "User not found." }, status: :not_found
    end
  end

  # Verify OTP and confirm WhatsApp number
  def update
    if @user && @user.confirm_whatsapp_number(params[:otp])
      render json: { message: "WhatsApp number confirmed successfully." }, status: :ok
    else
      render json: { error: "Invalid or expired OTP." }, status: :unprocessable_entity
    end
  end

  private

  def find_user
    @user = StarlinkUser.find_by(whatsapp_number: params[:whatsapp_number])
  end
end
