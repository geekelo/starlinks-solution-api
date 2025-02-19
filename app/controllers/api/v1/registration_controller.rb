class Api::V1::RegistrationController < ApplicationController
  def create
    if email_exists(signup_params[:email])
      render json: { errors: 'Email already exists' }, status: :unprocessable_entity
    elsif whatsapp_number_exists(signup_params[:whatsapp_number])
      render json: { errors: 'WhatsApp number already exists' }, status: :unprocessable_entity
    else
      user = StarlinkUser.new(signup_params)
      if user.save
        render json: user, status: :ok
      else
        render json: { errors: 'Something went wrong with creating user' }, status: :unprocessable_entity
      end
    end
  end

  private

  def signup_params
    params.require(:starlink_user).permit(:email, :password, :phone_number, :name, :whatsapp_number, :confirm_password)
  end

  def email_exists(email)
    StarlinkUser.exists?(email: email)
  end

  def whatsapp_number_exists(whatsapp_number)
    StarlinkUser.exists?(whatsapp_number: whatsapp_number)
  end
end
