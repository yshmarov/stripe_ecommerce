class CheckoutController < ApplicationController
  def create
    @order = @my_orders.find(params[:order_id])

    return redirect_to @order, notice: "Order must have at least one item" if @order.order_items.empty?
    return redirect_to @order, notice: "Order is not in draft status" unless @order.draft?
    return redirect_to @order, notice: t("orders.update.delivery_required") unless @order.delivery_selected?

    # https://docs.stripe.com/api/checkout/sessions/object
    session_params = {
      locale: I18n.locale == :ua ? :ru : I18n.locale,
      allow_promotion_codes: Setting.allow_promotion_codes,
      phone_number_collection: { enabled: Setting.phone_number_collection },
      billing_address_collection: Setting.billing_address_collection,
      automatic_tax: { enabled: Setting.automatic_tax },
      customer_creation: "always",
      shipping_options: shipping_options,
      shipping_address_collection: shipping_address_collection,
      # consent_collection: {
      # terms_of_service: "required",
      # },
      # adaptive_pricing: {
      #   enabled: true
      # },
      currency: @order.currency,
      line_items:,
      mode: "payment",
      success_url: order_url(@order),
      cancel_url: order_url(@order),
      client_reference_id: @order.id,
      metadata: delivery_metadata
    }.compact

    session = Stripe::Checkout::Session.create(session_params)

    redirect_to session.url, allow_other_host: true, status: :see_other
  end

  private

  def line_items
    @order.order_items.map do |order_item|
      {
        price: order_item.price.stripe_price_id,
        quantity: order_item.quantity
      }
    end
  end

  def fetch_shipping_rates
    return [] if Setting.shipping_countries.blank?

    rates = Stripe::ShippingRate.list(limit: 5, active: true)
    rates.data.map do |rate|
      { shipping_rate: rate.id }
    end
  end

  def shipping_options
    return [] unless @order.home_delivery?

    fetch_shipping_rates
  end

  def shipping_address_collection
    return nil unless @order.home_delivery?
    return nil if Setting.shipping_countries.blank?

    { allowed_countries: Setting.shipping_countries }
  end

  def delivery_metadata
    metadata = { delivery_method: @order.delivery_method }
    return metadata unless @order.inpost_delivery?

    metadata.merge(
      inpost_point_name: @order.inpost_point_name,
      inpost_point_address: @order.inpost_point_address
    ).compact
  end
end
