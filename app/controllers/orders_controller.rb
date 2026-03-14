class OrdersController < ApplicationController
  before_action :set_order, only: %i[show update]

  def index
    @orders = @my_orders.order(created_at: :desc).includes(:order_items)
  end

  def show
    @order_items = @order.order_items.order(created_at: :desc)
    @order.validate_order_items
  end

  def update
    if @order.draft?
      @order.update(delivery_params)
      respond_to do |format|
        format.turbo_stream { head :ok }
        format.html { redirect_back fallback_location: @order }
      end
      return
    end

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

  def order_params
    params.require(:order).permit(:rating)
  end

  def delivery_params
    params.require(:order).permit(:delivery_type, :inpost_point_name, :inpost_point_address)
  end
end
