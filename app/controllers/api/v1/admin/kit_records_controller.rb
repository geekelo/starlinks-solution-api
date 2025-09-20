class Api::V1::Admin::KitRecordsController < ApplicationController
  before_action :authenticate_token!

  # GET /api/v1/admin/kit_records
  def index
    kit_records = StarlinkKit.joins(:starlink_user, :starlink_kit_renewals)
  
    if params[:filter].present?
      filters = params[:filter]
  
      kit_records = kit_records.where(status: filters[:status]) if filters[:status].present?
      kit_records = kit_records.where("starlink_kits.address ILIKE ?", "%#{filters[:address]}%") if filters[:address].present?
      kit_records = kit_records.where("starlink_users.name ILIKE ?", "%#{filters[:owner_name]}%") if filters[:owner_name].present?
      kit_records = kit_records.where("starlink_users.email ILIKE ?", "%#{filters[:owner_email]}%") if filters[:owner_email].present?
      kit_records = kit_records.where("starlink_users.phone_number ILIKE ?", "%#{filters[:owner_phone_number]}%") if filters[:owner_phone_number].present?
      kit_records = kit_records.where(plan: filters[:plan]) if filters[:plan].present?
  
      # Date filters
      if filters[:date_added].present?
        kit_records = kit_records.where("DATE(starlink_kits.created_at) = ?", filters[:date_added])
      end
  
      if filters[:month_added].present?
        kit_records = kit_records.where("EXTRACT(MONTH FROM starlink_kits.created_at) = ?", filters[:month_added].to_i)
      end
  
      if filters[:year_added].present?
        kit_records = kit_records.where("EXTRACT(YEAR FROM starlink_kits.created_at) = ?", filters[:year_added].to_i)
      end
    end
  
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
  
    # pagination
    kit_data = kit_data.paginate(page: params[:page], per_page: params[:per_page] || 50)
  
    render json: {
      kits: kit_data,
      total_pages: kit_data.total_pages,
      total_count: kit_data.total_count
    }, status: :ok
  
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
