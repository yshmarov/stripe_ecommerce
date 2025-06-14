class OrderItemsController < ApplicationController
  before_action :set_order_item, only: [ :update, :destroy ]

  # increment or decrement the quantity of an order item
  def update
    @order_item.update(order_item_params)
    @order_item.calculate_total_amount
    flash[:notice] = t(".notice")
    redirect_back fallback_location: @order_item.order
  end

  def destroy
    @order_item.destroy
    @order_item.order.calculate_total_amount
    flash[:notice] = t(".notice")
    redirect_back fallback_location: @order_item.order
  end

  private

  def set_order_item
    @order = @my_orders.draft.find(params[:order_id])
    @order_item = @order.order_items.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, status: :not_found
  end

  def order_item_params
    params.require(:order_item).permit(:quantity)
  end
end
