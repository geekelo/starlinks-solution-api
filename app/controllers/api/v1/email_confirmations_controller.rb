class Api::V1::EmailConfirmationsController < ApplicationController
  before_action :authenticate_token!
  
  def create
    user = current_user

    if user
      token = user.generate_confirmation_token
      ConfirmationEmailMailer.send_confirmation_email(user, token).deliver_now
      render json: { message: "Email confirmatiom instructions sent to #{user.email}" }, status: :ok
    else
      render json: { error: 'Email not found' }, status: :not_found
    end
  end

  def confirm_user_email
    unless current_user.confirmation_token == params[:token]
      return render json: { error: "Invalid confirmation token" }, status: :unauthorized
    end
  
    user = current_user

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
