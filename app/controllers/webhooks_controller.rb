class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    payload = request.body.read
    sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
    endpoint_secret = ENV.fetch("STRIPE_WEBHOOK_SECRET")
    event = nil

    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, endpoint_secret
      )
    rescue JSON::ParserError => e
      status 400
      return
    rescue Stripe::SignatureVerificationError => e
      status 400
      return
    end

    case event.type
    when "checkout.session.completed"
      session = event.data.object
      order = Order.find(session.client_reference_id)
      order.update(checkout_session: session)
      rebuild_order_items(order, session)
      return unless session.payment_status == "paid"

      order.submitted! if order.draft?
    end

    render json: { status: "success" }
  end

  private

  # if customer chooses upsells/cross-sells during checkout
  def rebuild_order_items(order, session)
    # Fetch the line items and rebuild the order
    line_items = Stripe::Checkout::Session.list_line_items(session.id)
    # Remove existing items
    order.order_items.destroy_all

    # Create new order items based on what was actually purchased
    line_items.data.each do |item|
      product = Product.find_by("stripe_product->>'id' = ?", item.price.product)
      next unless product

      order.order_items.create!(
        product: product,
        quantity: item.quantity,
        price: item.price.unit_amount,
        total_price: item.amount_total
      )
    end

    order.calculate_total_price
  end
end
