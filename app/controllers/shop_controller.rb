class ShopController < ApplicationController
  def add_to_cart
    # find or create order
    order = @current_order.presence || Order.create(
      status: Order.statuses[:draft],
      user_id: current_guest_id
    )

    # add to cart
    product = Product.find(params[:product_id])
    order_item = order.order_items.find_or_create_by(product:)
    # add +1 item to cart
    order_item.increment!(:quantity)
    # balance calculation
    order_item.calculate_total_amount

    notice = "#{product.name} added to cart"

    redirect_back(fallback_location: products_path, notice:)
  end
end
