class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token
  attr_reader :current_user

  self.abstract_class = true

  private

  def authenticate_user!
    payload = JsonWebToken.decode(auth_token)
    @current_user = StarlinkUser.find(payload['user_id'])
  rescue JWT::DecodeError
    render json: { error: 'Invalid token' }, status: :unauthorized
  end

  def auth_token
    @auth_token ||= request.headers.fetch('authorization', '').split.last
  end
end
