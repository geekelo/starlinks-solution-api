class Api::V1::PasswordResetsController < ApplicationController
  def create
    user = StarlinkUser.find_by(email: params[:email])

    if user
      token = user.generate_password_reset_token
      PasswordResetMailer.send_reset_email(user, token).deliver_now
      render json: { message: "Password reset instructions sent to #{user.email}" }, status: :ok
    else
      render json: { error: 'Email not found' }, status: :not_found
    end
  end

  def update
    user = StarlinkUser.find_by(reset_password_token: params[:token])

    if user&.password_reset_token_valid?
      if user.reset_password(params[:password])
        render json: { message: 'Password has been reset' }, status: :ok
      else
        render json: { error: user.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: 'Invalid or expired token' }, status: :unauthorized
    end
  end
end
