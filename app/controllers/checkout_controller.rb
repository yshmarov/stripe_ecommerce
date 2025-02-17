class CheckoutController < ApplicationController
  def create
    @order = @my_orders.find(params[:order_id])

    return redirect_to @order, notice: "Order must have at least one item" if @order.order_items.empty?
    return redirect_to @order, notice: "Order is not in draft status" unless @order.draft?

    session = Stripe::Checkout::Session.create(
      payment_method_types: [ "card" ],
      line_items:,
      mode: "payment",
      success_url: order_url(@order),
      cancel_url: order_url(@order),
      client_reference_id: @order.id,
      metadata: {
        order_id: @order.id
      }
    )

    redirect_to session.url, allow_other_host: true, status: :see_other
  end

  # Approach without having to define Stripe products:
  # def line_items
  #   @order.order_items.map do |item|
  #     {
  #       price_data: {
  #         currency: Setting.currency.downcase,
  #         product_data: {
  #           name: item.product.name,
  #           description: item.product.description,
  #           images: [ item.product.image_url ]
  #         },
  #         unit_amount: item.price
  #       },
  #       quantity: item.quantity
  #     }
  #   end
  # end

  def line_items
    @order.order_items.map do |item|
      {
        price: item.product.stripe_price_id,
        quantity: item.quantity
      }
    end
  end
end
