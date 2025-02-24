Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      post "/signup", to: "registration#create"
      post "/login", to: "authentication#create"
      # get "starlink_kits/check_kit_number", to: "starlink_kits#check_kit_number"


      resources :password_resets, only: [:create, :update]
      
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
        member do
          get :kit_details
        end
        collection do
          put :kit_address_change_request
        end
      end
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
