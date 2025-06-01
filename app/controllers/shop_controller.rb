class ShopController < ApplicationController
  def add_to_cart
    # find or create order
    order = @current_order.presence || @current_account.orders.create(
      status: Order.statuses[:draft],
      user_id: current_guest_id,
      user_agent: request.user_agent,
      ip_address: request.ip
    )

    # add to cart
    price = @current_account.prices.find(params[:price_id])
    order_item = order.order_items.find_or_create_by(price:)
    # add +1 item to cart
    order_item.increment!(:quantity)
    # balance calculation
    order_item.calculate_total_amount

    flash[:notice] = t(".added_to_cart", product: price.product.name)

    redirect_back(fallback_location: products_path)
  end
end
