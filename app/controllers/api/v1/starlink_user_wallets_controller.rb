class Api::V1::StarlinkUserWalletsController < ApplicationController
  before_action :set_wallet, only: %i[show update destroy]

  # Create a wallet
  def create
    user = StarlinkUser.find_by(id: wallet_params[:starlink_user_id])

    return render json: { error: 'User not found' }, status: :not_found if user.nil?

    wallet = StarlinkUserWallet.new(wallet_params)

    if wallet.save
      render json: wallet, status: :created
    else
      render json: wallet.errors, status: :unprocessable_entity
    end
  end

  # Fetch all wallets
  def index
    wallets = StarlinkUserWallet.all
    render json: wallets, status: :ok
  end

  # Fetch a single wallet
  def show
    if @wallet
      render json: @wallet, status: :ok
    else
      render json: { error: 'Wallet not found' }, status: :not_found
    end
  end

  # Update wallet balance
  def update
    if @wallet.update(balance: wallet_params[:balance])
      render json: @wallet, status: :ok
    else
      render json: @wallet.errors, status: :unprocessable_entity
    end
  end

  # Delete a wallet
  def destroy
    @wallet.destroy
    render json: { message: 'Wallet deleted successfully' }, status: :ok
  end

  private

  def set_wallet
    @wallet = StarlinkUserWallet.find_by(id: params[:id])
  end

  def wallet_params
    params.require(:starlink_user_wallet).permit(:starlink_user_id)
  end
end
