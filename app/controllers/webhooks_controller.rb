class WebhooksController < ActionController::Base
  include ActionView::Helpers::NumberHelper
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper

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
    when "account.updated"
      account = Account.find_or_initialize_by(stripe_account_id: event.data.object.id)
      account.stripe_account = event.data.object
      account.save!
    when "product.updated", "product.created"
      Stripe::SyncProductJob.perform_later(event.data.object.id)
    when "product.deleted"
      Product.find_by(stripe_product_id: event.data.object.id).destroy!
    when "price.created", "price.updated"
      Stripe::SyncProductJob.perform_later(event.data.object.product)
    when "price.deleted"
      Price.find_by(stripe_price_id: event.data.object.id).destroy!
    when "checkout.session.completed"
      session = event.data.object
      order = Order.find(session.client_reference_id)
      order.update(checkout_session: session)
      rebuild_order_items(order, session)
      return unless session.payment_status == "paid"

      order.submitted! if order.draft?

      notify_admin_channel(order)
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
      price = Price.find_by(stripe_price_id: item.price.id)
      next unless price

      order.order_items.create!(
        price:,
        quantity: item.quantity,
        unit_amount: item.price.unit_amount,
        total_amount: item.amount_total
      )
    end

    order.calculate_total_amount
  end

  def notify_admin_channel(order)
    message = <<~MESSAGE
      Нове замовлення: #{order.obfuscated_id}

      #{link_to order.obfuscated_id, admin_order_url(order)}

      #{order.order_items.map { |item| "#{item.quantity}x #{item.price.name} - #{item.total_amount}" }.join("\n")}

      #{render_to_string(partial: "orders/checkout_details", locals: { order: })}
    MESSAGE

    Telegrama.send_message(message, disable_web_page_preview: true)
  end
end
