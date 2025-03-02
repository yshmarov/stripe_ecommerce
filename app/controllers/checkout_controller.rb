class CheckoutController < ApplicationController
  def create
    @order = @my_orders.find(params[:order_id])

    return redirect_to @order, notice: "Order must have at least one item" if @order.order_items.empty?
    return redirect_to @order, notice: "Order is not in draft status" unless @order.draft?

    # https://docs.stripe.com/api/checkout/sessions/object
    session = Stripe::Checkout::Session.create(
      locale: I18n.locale == :ua ? :ru : I18n.locale,
      allow_promotion_codes: Setting.allow_promotion_codes,
      phone_number_collection: { enabled: Setting.phone_number_collection },
      billing_address_collection: Setting.billing_address_collection,
      # automatic_tax: { enabled: true },
      shipping_address_collection: {
        allowed_countries: Setting.shipping_countries
      },
      customer_creation: "always",
      shipping_options: fetch_shipping_rates,
      # consent_collection: {
      # terms_of_service: "required",
      # },
      # adaptive_pricing: {
      #   enabled: true
      # },
      payment_method_types: [ "card" ],
      line_items:,
      mode: "payment",
      success_url: order_url(@order),
      cancel_url: order_url(@order),
      client_reference_id: @order.id
    )

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
    rates = Stripe::ShippingRate.list(limit: 5, active: true)
    rates.data.map do |rate|
      { shipping_rate: rate.id }
    end
  end
end
