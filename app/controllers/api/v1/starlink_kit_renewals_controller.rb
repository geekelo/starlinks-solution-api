class Api::V1::StarlinkKitRenewalsController < ApplicationController
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
