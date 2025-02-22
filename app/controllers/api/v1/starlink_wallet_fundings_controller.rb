class Api::V1::StarlinkWalletFundingsController < ApplicationController
  # POST /api/v1/starlink_wallet_fundings
  def create
    StarlinkUser.find(params[:starlink_user_id])
    funding = @starlink_user.starlink_wallet_fundings.new(funding_params)

    if funding.save
      render json: { message: 'Wallet funded successfully.', funding: }, status: :created
    else
      render json: { errors: funding.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def funding_params
    params.require(:starlink_wallet_funding).permit(:starlink_user_wallet_id, :amount, :payment_method)
  end
end
