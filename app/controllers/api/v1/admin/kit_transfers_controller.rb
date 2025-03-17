class Api::V1::Admin::KitTransfersController < ApplicationController
  before_action :authenticate_token!

  # POST /api/v1/admin/kit_transfers
  def transfer
    kit = StarlinkKit.find_by(kit_number: params[:kit_number])
    new_owner = StarlinkUser.find_by(email: params[:new_owner_email])

    if kit.nil?
      return render json: { error: "Kit not found." }, status: :not_found
    end

    if new_owner.nil?
      return render json: { error: "New owner not found." }, status: :not_found
    end

    ActiveRecord::Base.transaction do
      old_owner = kit.starlink_user
      kit.update!(starlink_user_id: new_owner.id)
    end

    render json: { message: "Kit successfully transferred to #{new_owner.email}." }, status: :ok
  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
end
