class Api::V1::Admin::FundingKitRequestsController < ApplicationController
  before_action :authenticate_token!

  # GET /api/v1/starlink_user_wallet_fundings/pending_paid
  def pending_paid
    fundings = StarlinkUserWalletFunding.where(paid: "yes", status: "pending")
    render json: { success: true, fundings: fundings }, status: :ok
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
end
