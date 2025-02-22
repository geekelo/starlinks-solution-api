class Api::V1::AuthenticationController < ApplicationController
  def create
    user = StarlinkUser.find_by(email: login_params[:email])
    if user&.authenticate(login_params[:password])
      token = encode_token(user.id)
      render json: {
        message: 'Welcome back!',
        user: StarlinkUserSerializer.new(user),
        token:
      }, status: :ok
    else
      render json: { errors: 'Invalid email or password' }, status: :unauthorized
    end
  end

  private

  def login_params
    params.require(:starlink_user).permit(:email, :password)
  end

  def encode_token(user_id)
    JsonWebToken.encode({ user_id: }, 'my_secret')
  end
end
