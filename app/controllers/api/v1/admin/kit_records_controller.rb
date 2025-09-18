class Api::V1::Admin::KitRecordsController < ApplicationController
  before_action :authenticate_token!

  # GET /api/v1/admin/kit_records
  def index
    kit_records = StarlinkKit.includes(:starlink_user, :starlink_kit_renewals)

    kit_data = kit_records.map do |kit|
      {
        id: kit.id,
        kit_number: kit.kit_number,
        owner_id: kit.starlink_user.id,
        owner_name: kit.starlink_user.name,
        owner_email: kit.starlink_user.email,
        owner_phone_number: kit.starlink_user.phone_number,
        status: kit.status,
        plan: kit.starlink_plan&.name,
        service_line_number: kit.service_line_number,
        address: kit.address,
        company_name: kit.company_name,
        company_number: kit.company_number,
        nin: kit.nin,
        created_at: kit.created_at,
        updated_at: kit.updated_at,
        last_renewal_deadline: kit.starlink_kit_renewals.order(deadline: :desc).first&.deadline,
        is_active: kit.starlink_kit_renewals.exists?(status: 'active'),
      }
    end

    # filter
    if params[:filter].present?
      kit_data = kit_data.where(status: params[:filter][:status]) if params[:filter][:status].present?
      kit_data = kit_data.where(owner_id: params[:filter][:owner_id]) if params[:filter][:owner_id].present?
      kit_data = kit_data.where(owner_name: params[:filter][:owner_name]) if params[:filter][:owner_name].present?
      kit_data = kit_data.where(owner_email: params[:filter][:owner_email]) if params[:filter][:owner_email].present?
      kit_data = kit_data.where(owner_phone_number: params[:filter][:owner_phone_number]) if params[:filter][:owner_phone_number].present?
      kit_data = kit_data.where(plan: params[:filter][:plan]) if params[:filter][:plan].present?
      kit_data = kit_data.where(service_line_number: params[:filter][:service_line_number]) if params[:filter][:service_line_number].present?
    end

    # pagination
    kit_data = kit_data.paginate(page: params[:page], per_page: params[:per_page] || 50)

    render json: { kits: kit_data, total_pages: kit_data.total_pages, total_count: kit_data.total_count }, status: :ok
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end

  def update
    kit = StarlinkKit.find_by(id: params[:id])
  
    if kit.nil?
      return render json: { error: 'Kit not found.' }, status: :not_found
    end
  
    if kit.update(kit_params)
      render json: { message: 'Kit details updated successfully.', kit: kit }, status: :ok
    else
      render json: { errors: kit.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def kit_params
    params.require(:starlink_kit).permit(:kit_number, :address, :company_name, :company_number, :nin, :status, :service_line_number)
  end
end
