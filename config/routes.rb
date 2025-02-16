Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root to: redirect("/shop")

  resources :products, only: %i[index show], path: "shop" do
    collection do
      get :search
      get :qr
    end
  end

  post "add_to_cart/:product_id", to: "shop#add_to_cart", as: :add_to_cart

  get "queue", to: "queue#index"

  resources :orders, except: %i[destroy new create edit] do
    resources :order_items, only: %i[destroy update]
  end

  namespace :admin do
    resource :settings
    resources :products, except: :show
    resources :orders, only: %i[index show update]
    resources :stats, only: :index
  end
end
