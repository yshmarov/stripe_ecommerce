Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root to: redirect("/shop")

  resources :products, only: %i[index show], path: "shop" do
    collection do
      get :search
    end
  end

  post "add_to_cart/:price_id", to: "shop#add_to_cart", as: :add_to_cart

  get "queue", to: "queue#index"

  resources :orders, only: %i[index show update] do
    resources :order_items, only: %i[destroy update]
    resources :checkout, only: [ :create ]
  end

  namespace :admin do
    resource :settings
    resources :orders, only: %i[index show update]
    resources :stats, only: :index
    mount GoodJob::Engine, at: "good_job"
  end

  resources :webhooks, only: [ :create ]

  get "terms_of_service", to: "static#terms_of_service"
  get "privacy_policy", to: "static#privacy_policy"
  get "refund_policy", to: "static#refund_policy"
end
