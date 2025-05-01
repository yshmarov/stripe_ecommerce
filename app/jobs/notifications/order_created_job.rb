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
      Нове замовлення: #{order.obfuscated_id}
      #{admin_order_url(order)}

      #{order.order_items.map { |item| "#{item.quantity}x #{item.price.product.name} - #{number_to_currency(item.total_amount / 100.0, unit: currency_code_to_symbol(item.price.stripe_price_object.currency))}" }.join("\n")}

      Доставка: #{number_to_currency(order.stripe_checkout_session_object.total_details.amount_shipping.to_f / 100, unit: currency_code_to_symbol(order.currency))}
      Податок: #{number_to_currency(order.stripe_checkout_session_object.total_details.amount_tax.to_f / 100, unit: currency_code_to_symbol(order.currency))}
      Знижка: #{number_to_currency(-order.stripe_checkout_session_object.total_details.amount_discount.to_f / 100, unit: currency_code_to_symbol(order.currency))}
      Загальна сума: #{number_to_currency(order.total_amount / 100.0, unit: currency_code_to_symbol(order.currency))}

      Адреса доставки:
      #{order.stripe_checkout_session_object.collected_information.shipping_details.address.values.compact.join(", ")}

      Ім'я:
      #{order.stripe_checkout_session_object.customer_details.name}

      Email:
      #{order.stripe_checkout_session_object.customer_details.email}

      Телефон:
      #{order.stripe_checkout_session_object.customer_details.phone}
    MESSAGE
    Telegrama.send_message(message, disable_web_page_preview: true)
  end
end
