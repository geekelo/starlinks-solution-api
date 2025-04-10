class Api::V1::Admin::FundingKitRequestsController < ApplicationController
  before_action :authenticate_token!

  # GET /api/v1/starlink_user_wallet_fundings/pending_paid
  def pending_paid
    fundings = StarlinkWalletFunding
                 .includes(:starlink_user, :starlink_user_wallet) # assuming associations exist
                 .where(paid: "yes", status: "need_approval")
  
    formatted_fundings = fundings.map do |funding|
      {
        id: funding.id,
        transaction_id: funding.transaction_id,
        amount: funding.amount,
        status: funding.status,
        paid: funding.paid,
        created_at: funding.created_at,
        updated_at: funding.updated_at,
        user_name: funding.starlink_user&.name,
        user_email: funding.starlink_user&.email,
        wallet_id: funding.starlink_user_wallet&.wallet_id,
        wallet_balance: funding.starlink_user_wallet&.balance
      }
    end
  
    render json: { success: true, fundings: formatted_fundings }, status: :ok
  rescue StandardError => e
    render json: { success: false, error: e.message }, status: :unprocessable_entity
  end  

  # Fetch all Starlink Kits where status = "pending"
  def pending_starlink_kits
    kits = StarlinkKit.where(status: "pending")
    render json: kits, status: :ok
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end

  def update_funding_request
    funding = StarlinkWalletFunding.find(params[:id])
  
    if funding.update(update_funding_params)
      # Only update the user's wallet balance if the status is "approved"
      if funding.status == "approved"
        user_wallet = funding.starlink_user_wallet
        if user_wallet
          user_wallet.update!(balance: user_wallet.balance + funding.amount)
        end
      end
  
      render json: { message: 'Funding status updated successfully.', funding: funding }, status: :ok
    else
      render json: { errors: funding.errors.full_messages }, status: :unprocessable_entity
    end
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end

  def update_kit_status
    starlink_kit = StarlinkKit.find_by(id: params[:id])
  
    if starlink_kit
      if starlink_kit.update(update_kit_params)
        render json: { message: 'Kit status updated successfully.', kit: starlink_kit }, status: :ok
      else
        render json: { errors: starlink_kit.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: 'Kit not found.' }, status: :not_found
    end
  end
  
  private

  def update_funding_params
    params.require(:starlink_wallet_funding).permit(:status, :amount)
  end

  def update_kit_params
    params.require(:starlink_kit).permit(:status, :starlink_plan_id)
  end
end
