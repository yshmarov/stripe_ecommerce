class ApplicationController < ActionController::Base
  include SetLocale

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
end
