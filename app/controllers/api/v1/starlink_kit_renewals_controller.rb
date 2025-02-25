class Api::V1::StarlinkKitRenewalsController < ApplicationController
  before_action :authenticate_token!

  def user_kit_renewals
    kit_id = params[:kit_id]
    wallet = current_user&.starlink_user_wallet
  
    if wallet.nil?
      render json: { error: "Wallet not found" }, status: :not_found and return
    end
  
    renewals = wallet.starlink_kit_renewals.where(
      starlink_kit_id: kit_id, 
      starlink_user_id: current_user.id
    )
  
    if renewals.any?
      render json: renewals, status: :ok
    else
      render json: { message: "No renewals found for this kit" }, status: :not_found
    end
  end

  def download_renewal_pdf
    renewal = StarlinkKitRenewal.find_by(id: params[:id])

    unless renewal
      render json: { error: "Renewal not found" }, status: :not_found and return
    end

    pdf_content = renewal.generate_renewal_pdf
    document_title = renewal.status == "invoice" ? "Renewal Invoice" : "Renewal Receipt"

    send_data pdf_content,
              filename: "#{document_title}_#{renewal.starlink_kit_id}.pdf",
              type: "application/pdf",
              disposition: "inline"
  end
end
