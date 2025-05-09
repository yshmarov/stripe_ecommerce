class Notifications::OrderCreatedJob < ApplicationJob
  include ActionView::Helpers::NumberHelper
  include Rails.application.routes.url_helpers
  include ApplicationHelper

  queue_as :default

  def perform(order)
    default_url_options[:host] = if Rails.env.production?
      Rails.application.config.action_mailer.default_url_options[:host]
    else
      "localhost:3000"
    end

    message = <<~MESSAGE
      🛍️ *New Order: #{order.obfuscated_id}*

      #{admin_order_url(order)}

      *Order Items*
      #{order.order_items.map { |item| "• #{item.quantity}x #{item.price.product.name} - #{number_to_currency(item.total_amount / 100.0, unit: currency_code_to_symbol(item.price.stripe_price_object.currency))}" }.join("\n")}

      *Order Summary*
      • Delivery: #{number_to_currency(order.stripe_checkout_session_object.total_details.amount_shipping.to_f / 100, unit: currency_code_to_symbol(order.currency))}
      • Tax: #{number_to_currency(order.stripe_checkout_session_object.total_details.amount_tax.to_f / 100, unit: currency_code_to_symbol(order.currency))}
      • Discount: #{number_to_currency(-order.stripe_checkout_session_object.total_details.amount_discount.to_f / 100, unit: currency_code_to_symbol(order.currency))}
      • Subtotal: #{number_to_currency(order.total_amount / 100.0, unit: currency_code_to_symbol(order.currency))}
      • Total: #{number_to_currency((order.total_amount + order.stripe_checkout_session_object.total_details.amount_shipping.to_f + order.stripe_checkout_session_object.total_details.amount_tax.to_f - order.stripe_checkout_session_object.total_details.amount_discount.to_f) / 100.0, unit: currency_code_to_symbol(order.currency))}

      *Delivery Address*
      #{order.stripe_checkout_session_object.collected_information.shipping_details.address.values.compact.join(", ")}

      *Customer Details*
      • Name: #{order.stripe_checkout_session_object.customer_details.name}
      • Email: #{order.stripe_checkout_session_object.customer_details.email}
      • Phone: #{order.stripe_checkout_session_object.customer_details.phone}
    MESSAGE
    Telegrama.send_message(message, parse_mode: "MarkdownV2", disable_web_page_preview: true)
    # TODO: display delivery option (home/inpost)
  end
end
