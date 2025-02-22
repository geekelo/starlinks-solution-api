class Api::V1::EmailConfirmationsController < ApplicationController
  def create
    user = StarlinkUser.find_by(email: params[:email])

    if user
      token = user.generate_confirmation_token
      ConfirmationEmailMailer.send_confirmation_email(user, token).deliver_now
      render json: { message: "Email confirmatiom instructions sent to #{user.email}" }, status: :ok
    else
      render json: { error: 'Email not found' }, status: :not_found
    end
  end

  def confirm_user_email
    user = StarlinkUser.find_by(confirmation_token: params[:token])

    if user&.confirmation_token_valid?
      if user.confirm_email
        render json: { message: 'Email has been confirmed' }, status: :ok
      else
        render json: { error: user.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: 'Invalid or expired token' }, status: :unauthorized
    end
  end
end
