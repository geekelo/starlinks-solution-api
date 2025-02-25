
module Api
  module V1
    class AuthenticationController < ApplicationController
      def create
        user = StarlinkUser.find_by(email: login_params[:email])
        if user&.authenticate(login_params[:password])
          render json: {
            message: 'User is logged in',
            user: StarlinkUserSerializer.new(user),
            token: JsonWebToken.encode({ sub: user.id })
          }, status: :ok
        else
          render json: { error: 'Invalid credentials' }, status: :unauthorized
        end
      end
      private

      def login_params
        params.require(:starlink_user).permit(:email, :password)
      end
    end
  end
end