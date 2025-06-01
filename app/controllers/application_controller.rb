class ApplicationController < ActionController::Base
  include SetLocale

  before_action :current_account
  helper_method :current_account

  before_action :current_guest_id
  helper_method :current_guest_id

  before_action :set_orders

  after_action :record_page_view

  protected

  def record_page_view
    # This is a basic example, you might need to customize some conditions.
    # For most sites, it makes no sense to record anything other than HTML.
    if response.content_type && response.content_type.start_with?("text/html")
      # Add a condition to record only your canonical domain
      # and use a gem such as crawler_detect to skip bots.
      ActiveAnalytics.record_request(request)
    end
  end

  def set_orders
    @my_orders ||= Order.where(user_id: current_guest_id)
    @current_order ||= @my_orders.draft.first
  end

  def current_guest_id
    cookies.permanent.signed[:guest_id] ||= SecureRandom.uuid
  end

  def current_account
    @current_account ||= Account.first_or_create! do |account|
      stripe_account = Stripe::Account.retrieve
      account.stripe_account_id = stripe_account.id
      account.stripe_account = stripe_account
    end
    @stripe_account = @current_account.stripe_account_object
    @stripe_logo_url = @current_account.stripe_logo_url
  end
end
