class Api::V1::StarlinkWalletFundingsController < ApplicationController
  before_action :authenticate_token!

  def index
    user = current_user
    if user
      fundings = StarlinkWalletFunding.where(starlink_user_id: user.id)
      if fundings.present?
        render json: fundings, status: :ok
      else
        render json: { message: 'No fundings found.' }, status: :ok
      end
    else
      render json: { error: 'User not authenticated.' }, status: :unauthorized
    end
  end

  # POST /api/v1/starlink_wallet_fundings
  def create
    starlink_user = current_user
    funding = starlink_user.starlink_wallet_fundings.new(funding_params)

    if funding.save
      render json: { message: 'Wallet funded successfully.', funding: }, status: :created
    else
      render json: { errors: funding.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def confirm_request
    funding = StarlinkWalletFunding.find(params[:id])
    if funding.update(confirm_funding_params)
      render json: { message: 'payment confirmation updated successfully.', funding: funding }, status: :ok
    else
      render json: { errors: funding.errors.full_messages }, status: :unprocessable_entity
    end
  end


  def approve_request
    funding = StarlinkWalletFunding.find(params[:id])
    if funding.update(update_funding_params)
      render json: { message: 'Funding status updated successfully.', funding: funding }, status: :ok
    else
      render json: { errors: funding.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def funding_params
    params.require(:starlink_wallet_funding).permit(:starlink_user_wallet_id, :amount, :payment_method, :starlink_user_id)
  end

  def confirm_funding_params
    params.require(:starlink_wallet_funding).permit(:paid)
  end

  def update_funding_params
    params.require(:starlink_wallet_funding).permit(:status)
  end
end
