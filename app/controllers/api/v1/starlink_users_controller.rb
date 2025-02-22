class Api::V1::StarlinkUsersController < ApplicationController
  # PATCH /api/v1/starlink_users/:id/update_email
  def update_email
    user = StarlinkUser.find_by(id: params[:id])
    unless user
      render json: { error: "User not found" }, status: :not_found and return
    end

    new_email = params[:email]
    if new_email.present? && new_email != user.email
      if user.update(email: new_email, email_confirmed: false)
        render json: { message: "Email updated successfully. Please verify your new email.", user: user }, status: :ok
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { message: "No change detected for email." }, status: :ok
    end
  end

  # PATCH /api/v1/starlink_users/:id/update_phone_number
  def update_phone_number
    user = StarlinkUser.find_by(id: params[:id])
    unless user
      render json: { error: "User not found" }, status: :not_found and return
    end

    new_phone_number = params[:phone_number]
    if new_phone_number.present? && new_phone_number != user.phone_number
      if user.update(phone_number: new_phone_number)
        render json: { message: "Phone number updated successfully.", user: user }, status: :ok
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { message: "No change detected for phone number." }, status: :ok
    end
  end

  # PATCH /api/v1/starlink_users/:id/update_whatsapp_number
  def update_whatsapp_number
    user = StarlinkUser.find_by(id: params[:id])
    unless user
      render json: { error: "User not found" }, status: :not_found and return
    end

    new_whatsapp_number = params[:whatsapp_number]
    if new_whatsapp_number.present? && new_whatsapp_number != user.whatsapp_number
      if user.update(whatsapp_number: new_whatsapp_number, whatsapp_number_confirmed: false)
        render json: { message: "WhatsApp number updated successfully. Please verify your new WhatsApp number.", user: user }, status: :ok
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { message: "No change detected for WhatsApp number." }, status: :ok
    end
  end

  def check_confirmation_status
    user = StarlinkUser.find_by(id: params[:id])
    unless user
      render json: { error: "User not found" }, status: :not_found and return
    end

    render json: { email_confirmed: user.email_confirmed, whatsapp_number_confirmed: user.whatsapp_number_confirmed }, status: :ok
  end
end
