class CheckoutController < ApplicationController
  def create
    @order = @my_orders.find(params[:order_id])

    return redirect_to @order, notice: "Order must have at least one item" if @order.order_items.empty?
    return redirect_to @order, notice: "Order is not in draft status" unless @order.draft?
    return redirect_to @order, alert: t("orders.delivery.required") unless @order.delivery_selection_complete?

    # https://docs.stripe.com/api/checkout/sessions/object
    session = Stripe::Checkout::Session.create(checkout_session_params)

    redirect_to session.url, allow_other_host: true, status: :see_other
  end

  private

  def checkout_session_params
    params = {
      locale: I18n.locale == :ua ? :ru : I18n.locale,
      allow_promotion_codes: Setting.allow_promotion_codes,
      phone_number_collection: { enabled: Setting.phone_number_collection },
      billing_address_collection: Setting.billing_address_collection,
      automatic_tax: { enabled: Setting.automatic_tax },
      customer_creation: "always",
      currency: @order.currency,
      line_items:,
      mode: "payment",
      success_url: order_url(@order),
      cancel_url: order_url(@order),
      client_reference_id: @order.id,
      metadata: @order.checkout_metadata
    }

    if @order.home_delivery?
      params[:shipping_address_collection] = {
        allowed_countries: Setting.shipping_countries
      }
      params[:shipping_options] = fetch_shipping_rates
    end

    params
  end

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
end
