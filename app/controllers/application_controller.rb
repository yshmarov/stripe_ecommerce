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
    @account = Account.first_or_create!(
      stripe_account_id: Stripe::Account.retrieve.id,
      stripe_account: Stripe::Account.retrieve.to_hash
    )
    @stripe_account = @account.stripe_account_object
    @stripe_logo_url = @account.stripe_logo_url
  end
end
