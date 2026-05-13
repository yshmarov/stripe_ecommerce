class OrdersController < ApplicationController
  before_action :set_order, only: %i[show update]

  def index
    @orders = @my_orders.order(created_at: :desc).includes(:order_items)
  end

  def show
    @order_items = @order.order_items.order(created_at: :desc)
    @order.validate_order_items
  end

  # add rating to order
  def update
    if @order.draft? && delivery_selection_params?
      return redirect_back fallback_location: @order, notice: t(".delivery_saved") if @order.update(delivery_params)

      return redirect_back fallback_location: @order, alert: @order.errors.full_messages.to_sentence
    end

    return redirect_to @order, notice: "Order is not completed yet" unless @order.done?

    @order.update(rating_params)
    redirect_back fallback_location: @order, notice: t(".rating")
  end

  private

  def set_order
    @order = @my_orders.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to orders_path
  end

  def rating_params
    params.require(:order).permit(:rating)
  end

  def delivery_params
    attrs = params.require(:order).permit(:delivery_method, delivery_details: [ :point_name, :point_address ]).to_h
    attrs["delivery_details"] = {} if attrs["delivery_method"] == "home_delivery"
    attrs
  end

  def delivery_selection_params?
    order = params[:order]
    order.present? && (order.key?(:delivery_method) || order.key?("delivery_method") || order.key?(:delivery_details) || order.key?("delivery_details"))
  end
end
