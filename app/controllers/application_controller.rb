class ApplicationController < ActionController::Base
  attr_reader :current_user

  private

  def authenticate_token!
    payload = JsonWebToken.decode(auth_token)
    @current_user = StarlinkUser.find(payload['user_id'])
  rescue JWT::DecodeError
    render json: { error: 'Invalid auth token' }, status: :unauthorized
  end

  def auth_token
    @auth_token ||= request.headers.fetch('authorization', '').split.last
  end
end
