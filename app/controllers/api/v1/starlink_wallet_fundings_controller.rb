class Api::V1::StarlinkWalletFundingsController < ApplicationController
  before_action :authenticate_token!

  def index
    user = current_user
    if user
      fundings = StarlinkWalletFunding.where(starlink_user_id: user.id)
  
      if fundings.present?
        # Expire fundings where 'paid' is false and older than 2 hours
        fundings.where(paid: "no", status: "pending")
                .where("created_at <= ?", 2.hours.ago)
                .update_all(status: "expired")
  
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
    funding = current_user.starlink_wallet_fundings.find(params[:id])

    if params[:starlink_wallet_funding][:paid].to_s.downcase == "yes"
      if funding.update(confirm_funding_params.merge(status: "need_approval"))
        render json: { message: 'Payment confirmation updated successfully.', funding: funding }, status: :ok
      else
        render json: { errors: funding.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { message: 'No update performed since payment is not confirmed.' }, status: :ok
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
