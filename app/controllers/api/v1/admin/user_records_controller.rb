class Api::V1::Admin::UserRecordsController < ApplicationController
  before_action :authenticate_token!

  # GET /api/v1/admin/user_records
  def index
    user_records = StarlinkUser.where(role: 'user').includes(:starlink_kits, :starlink_user_wallet)
    user_records = user_records.order(created_at: :desc)

    # filter by name, email, phone_number, whatsapp_number, wallet_id
    filterName = params[:filter][:name] if params[:filter][:name].present?
    filterEmail = params[:filter][:email] if params[:filter][:email].present?
    filterPhoneNumber = params[:filter][:phone_number] if params[:filter][:phone_number].present?
    filterWhatsappNumber = params[:filter][:whatsapp_number] if params[:filter][:whatsapp_number].present?
    filterWalletId = params[:filter][:wallet_id] if params[:filter][:wallet_id].present?

    user_records = user_records.where("name ILIKE ?", "%#{filterName}%") if filterName.present?
    user_records = user_records.where("email ILIKE ?", "%#{filterEmail}%") if filterEmail.present?
    user_records = user_records.where("phone_number ILIKE ?", "%#{filterPhoneNumber}%") if filterPhoneNumber.present?
    user_records = user_records.where("whatsapp_number ILIKE ?", "%#{filterWhatsappNumber}%") if filterWhatsappNumber.present?
    user_records = user_records.joins(:starlink_user_wallet).where(starlink_user_wallets: { wallet_id: filterWalletId }) if filterWalletId.present?

    user_data = user_records.map do |user|
      {
        id: user.id,
        email: user.email,
        phone_number: user.phone_number,
        name: user.name,
        whatsapp_number: user.whatsapp_number,
        email_confirmed: user.email_confirmed,
        whatsapp_number_confirmed: user.whatsapp_number_confirmed,
        created_at: user.created_at,
        updated_at: user.updated_at,
        wallet_id: user.starlink_user_wallet.wallet_id,
        wallet_balance: user.starlink_user_wallet.balance,
        kits_owned: user.starlink_kits.count,
      }
    end

    # pagination
    user_records = user_records.paginate(page: params[:page], per_page: params[:per_page] || 50)

    render json: { user_data: user_data, total_pages: user_records.total_pages, total_count: user_records.total_count }, status: :ok
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end

  def update
    user = StarlinkUser.find_by(id: params[:id], role: 'user')
  
    if user.nil?
      return render json: { error: 'User not found.' }, status: :not_found
    end
  
    if user.update(user_params)
      render json: { message: 'User details updated successfully.', user: user }, status: :ok
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:starlink_user).permit(:email, :phone_number, :name, :whatsapp_number, :email_confirmed, :whatsapp_number_confirmed)
  end
end
