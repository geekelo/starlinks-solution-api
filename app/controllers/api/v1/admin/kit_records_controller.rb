class Api::V1::Admin::KitRecordsController < ApplicationController
  before_action :authenticate_token!

  # GET /api/v1/admin/kit_records
  def index
    # Build the base query with proper includes to avoid N+1 queries
    kit_records = StarlinkKit.includes(
      :starlink_user, 
      :starlink_plan,
      starlink_kit_renewals: []
    )

    # Apply database-level filtering first for better performance
    kit_records = apply_filters(kit_records)

    # Use a single query with subqueries to get renewal data efficiently
    kit_records = kit_records.left_joins(:starlink_kit_renewals)
      .select(
        'starlink_kits.*',
        'starlink_users.id as owner_id',
        'starlink_users.name as owner_name', 
        'starlink_users.email as owner_email',
        'starlink_users.phone_number as owner_phone_number',
        'starlink_plans.name as plan_name',
        '(SELECT MAX(deadline) FROM starlink_kit_renewals WHERE starlink_kit_id = starlink_kits.id) as last_renewal_deadline',
        '(SELECT COUNT(*) > 0 FROM starlink_kit_renewals WHERE starlink_kit_id = starlink_kits.id AND status = \'active\') as is_active'
      )
      .group('starlink_kits.id, starlink_users.id, starlink_plans.id')

    # Apply pagination at database level
    kit_records = kit_records.page(params[:page]).per(params[:per_page] || 50)

    # Transform to hash format efficiently
    kit_data = kit_records.map do |kit|
      {
        id: kit.id,
        kit_number: kit.kit_number,
        owner_id: kit.owner_id,
        owner_name: kit.owner_name,
        owner_email: kit.owner_email,
        owner_phone_number: kit.owner_phone_number,
        status: kit.status,
        plan: kit.plan_name,
        service_line_number: kit.service_line_number,
        address: kit.address,
        company_name: kit.company_name,
        company_number: kit.company_number,
        nin: kit.nin,
        created_at: kit.created_at,
        updated_at: kit.updated_at,
        last_renewal_deadline: kit.last_renewal_deadline,
        is_active: kit.is_active,
      }
    end

    render json: { 
      kits: kit_data, 
      total_pages: kit_records.total_pages, 
      total_count: kit_records.total_count 
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

  def apply_filters(query)
    return query unless params[:filter].present?

    filter_params = params[:filter]
    
    # Apply database-level filters for better performance
    query = query.where(status: filter_params[:status]) if filter_params[:status].present?
    query = query.where(address: filter_params[:address]) if filter_params[:address].present?
    query = query.joins(:starlink_user).where(starlink_users: { name: filter_params[:owner_name] }) if filter_params[:owner_name].present?
    query = query.joins(:starlink_user).where(starlink_users: { email: filter_params[:owner_email] }) if filter_params[:owner_email].present?
    query = query.joins(:starlink_user).where(starlink_users: { phone_number: filter_params[:owner_phone_number] }) if filter_params[:owner_phone_number].present?
    query = query.joins(:starlink_plan).where(starlink_plans: { name: filter_params[:plan] }) if filter_params[:plan].present?
    
    # Date filtering
    if filter_params[:date_added].present?
      date = Date.parse(filter_params[:date_added]) rescue nil
      query = query.where(created_at: date.beginning_of_day..date.end_of_day) if date
    end
    
    # Month filtering (e.g., "09")
    if filter_params[:month_added].present?
      month = filter_params[:month_added].to_i
      query = query.where("EXTRACT(month FROM created_at) = ?", month) if month.between?(1, 12)
    end
    
    # Year filtering (e.g., "2025")
    if filter_params[:year_added].present?
      year = filter_params[:year_added].to_i
      query = query.where("EXTRACT(year FROM created_at) = ?", year) if year > 0
    end
    
    query
  end

  def kit_params
    params.require(:starlink_kit).permit(:kit_number, :address, :company_name, :company_number, :nin, :status, :service_line_number)
  end
end
