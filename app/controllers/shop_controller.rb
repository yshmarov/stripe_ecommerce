class ShopController < ApplicationController
  # the default url to open from QR
  # http://localhost:3000/qr?table_delivery=3
  def qr
    session[:table_delivery] = params[:table_delivery]
    redirect_to products_path
  end

  def add_to_cart
    # set delivery delivery
    delivery_details = session[:table_delivery].presence || "To go"
    # find or create order
    order = @current_order.presence || Order.create(
      status: Order.statuses[:draft],
      delivery_details:,
      user_id: current_guest_id
    )
    # clear table for next order creation
    session[:table_delivery] = nil

    # add to cart
    product = Product.find(params[:product_id])
    order_item = order.order_items.find_or_create_by(product:)
    # add +1 item to cart
    order_item.increment!(:quantity)
    # balance calculation
    order_item.calculate_total_price

    notice = "#{product.name} added to cart"

    redirect_back(fallback_location: products_path, notice:)
  end
end
