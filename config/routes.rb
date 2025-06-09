Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      post "/signup", to: "registration#create"
      post "/login", to: "authentication#create"

      get "starlink_kit_renewals/user_kit_renewals", to: "starlink_kit_renewals#user_kit_renewals"
      get "starlink_kit_renewals/:id/download_pdf", to: "starlink_kit_renewals#download_renewal_pdf"
      post 'starlink_activates/:kit_id/activate_kit', to: 'starlink_activates#activate_kit'
      # POST /api/v1/starlink_activates/1234-5678-9101/activate_kit

      namespace :admin do
        post "send_invoice_reminders", to: "invoice_reminders#send_reminders"
      
           # Funding Kit Requests
        resources :funding_kit_requests, only: [] do
          collection do
            get 'pending_paid'          # GET /api/v1/admin/funding_kit_requests/pending_paid
            get 'pending_starlink_kits' # GET /api/v1/admin/funding_kit_requests/pending_starlink_kits
          end
          member do
            patch 'update_funding_request' # PATCH /api/v1/admin/funding_kit_requests/:id/update_funding_request
            patch 'update_kit_status'      # PATCH /api/v1/admin/funding_kit_requests/:id/update_kit_status
          end
        end

        # Kit Autorenews and single force renews
        resources :kit_autorenews, only: [] do
          collection do
            get 'auto_renew_kits' # GET /api/v1/admin/kit_autorenews/auto_renew_kits
            post 'renew_specific_kit' # POST /api/v1/admin/kit_autorenews/renew_specific_kit
          end
        end

        # Deactivate expired kits
        resources :kit_deactivations do
          collection do
            get 'deactivate_expired_kits' # GET /api/v1/admin/kit_deactivations/deactivate_expired_kits
          end
        end
  
        # Kit Transfers
        resources :kit_transfers, only: [] do
          collection do
            post 'transfer' # POST /api/v1/admin/kit_transfers/transfer
            post 'add_kit_to_user' # POST /api/v1/admin/kit_transfers/add_kit_to_user
          end
        end

        # Kit Records
        resources :kit_records, only: [:index, :update]

        # Wallet Histories
        resources :wallet_histories, only: [:index] do
          collection do
            get :admin_balance
          end
        end

        # Wallet Withdrawals
        resources :starlink_admin_withdrawals, only: [:create]

        # User records
        resources :user_records, only: [:index, :update]
      
        # User Fundings
        resources :user_fundings, only: [:index, :create, :update]

        # Kit Renewals
        resources :kit_renewals, only: [:index, :create, :update, :destroy]
      end

      resources :password_resets, only: [:create, :update], param: :code
      
      resources :email_confirmations do
        collection do
          put :confirm_user_email
        end
      end

      resources :whatsapp_confirmations do
        collection do
          post :create
          put :confirm_user_whatsapp
        end
      end

      resources :starlink_plans
      resources :starlink_user_wallets
      resource :starlink_user_wallet, only: [:show]

      resources :starlink_users do
        collection do
          put :email_change_request
          put :phone_number_change_request
          put :whatsapp_number_change_request
          get :check_confirmation_status
        end
      end

      resources :starlink_wallet_fundings do
        collection do
          put :confirm_request
          put :approve_request
        end
      end

      resources :starlink_kits do
        collection do
          put :kit_address_change_request
          get :check_kit_number
          put :set_auto_renew
        end
      end
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
