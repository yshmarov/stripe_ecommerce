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
    return update_delivery if delivery_update?
    return redirect_to @order, notice: "Order is not completed yet" unless @order.done?

    @order.update(order_params)
    redirect_back fallback_location: @order, notice: t(".rating")
  end

  private

  def set_order
    @order = @my_orders.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to orders_path
  end

  def delivery_update?
    params.dig(:order, :delivery_method).present? || params.dig(:order, :delivery_details).present?
  end

  def update_delivery
    return redirect_to @order, alert: t("orders.delivery.locked") unless @order.draft?

    if @order.update(delivery_order_params)
      redirect_to @order, notice: t("orders.delivery.saved")
    else
      @order_items = @order.order_items.order(created_at: :desc)
      flash.now[:alert] = @order.errors.full_messages.to_sentence
      render :show, status: :unprocessable_entity
    end
  end

  def order_params
    params.require(:order).permit(:rating)
  end

  def delivery_order_params
    permitted = params.require(:order).permit(:delivery_method, delivery_details: %i[address point_name point_address])
    {
      delivery_method: permitted[:delivery_method],
      delivery_details: permitted[:delivery_details]&.to_h || {}
    }
  end
end
