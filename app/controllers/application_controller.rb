class ApplicationController < ActionController::Base
  include SetLocale

  before_action :set_stripe_account
  before_action :current_guest_id
  helper_method :current_guest_id

  before_action :set_orders

  protected

  def set_orders
    @my_orders ||= Order.where(user_id: current_guest_id)
    @current_order ||= @my_orders.draft.first
  end

  def current_guest_id
    cookies.permanent.signed[:guest_id] ||= SecureRandom.uuid
  end

  def set_stripe_account
    # Rails.cache.delete("stripe_account")
    @stripe_account ||= Rails.cache.fetch("stripe_account", expires_in: 1.hour) do
      Stripe::Account.retrieve
    end

    stripe_logo_id = @stripe_account.settings.branding.logo
    if stripe_logo_id.present?
      # Rails.cache.delete("stripe_logo_url_#{stripe_logo_id}")
      @stripe_logo_url = Rails.cache.fetch("stripe_logo_url_#{stripe_logo_id}", expires_in: 1.hour) do
        file = Stripe::File.retrieve(stripe_logo_id)
        file.links.first.url
      end
    end
  end
end
