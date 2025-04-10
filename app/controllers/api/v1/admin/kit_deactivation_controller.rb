class Api::V1::Admin::KitDeactivationsController < ApplicationController
  before_action :authenticate_token!  # or :authenticate_admin!

  def deactivate_expired_kits
    today = Date.today

    kits = StarlinkKit.includes(:starlink_kit_renewals)

    deactivated_count = 0

    kits.find_each do |kit|
      renewal = kit.starlink_kit_renewals
                   .where(status: "invoice")
                   .order(deadline: :desc)
                   .first

      next unless renewal && renewal.deadline < today

      kit.update!(status: 'deactivated')
      renewal.destroy unless renewal.prorated
      deactivated_count += 1
    end

    render json: { message: "Expired kits deactivated", count: deactivated_count }, status: :ok
  end
end
