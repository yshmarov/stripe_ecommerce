class OrdersController < ApplicationController
  before_action :set_order, only: %i[show update]

  def index
    @orders = @my_orders.order(created_at: :desc)
  end

  def show
    @order_items = @order.order_items.order(created_at: :desc)
  end

  # add rating to order
  def update
    return redirect_to @order, notice: "Order is not completed yet" unless @order.done?

    @order.update(order_params)
    redirect_to @order, notice: t(".rating")
  end

  private

  def set_order
    @order = @my_orders.find(params[:id])
  end

  def order_params
    params.require(:order).permit(:rating)
  end
end
