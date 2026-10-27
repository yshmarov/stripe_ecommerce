require "test_helper"

class Notifications::OrderCreatedJobTest < ActiveJob::TestCase
  setup do
    @account = accounts(:one)
  end

  test "includes inpost delivery option and locker address in telegram notification" do
    order = build_submitted_order(
      delivery_method: "inpost",
      delivery_details: {
        "point_name" => "WAW01A",
        "point_address" => "Stawki 2, 00-193 Warszawa"
      }
    )

    sent_messages = capture_telegram_messages do
      Notifications::OrderCreatedJob.perform_now(order)
    end

    assert_equal 1, sent_messages.size
    message_text, options = sent_messages.first
    assert_equal({ parse_mode: "MarkdownV2", disable_web_page_preview: true }, options)
    assert_includes message_text, "*Delivery Option*\nInPost"
    assert_includes message_text, "*Delivery Address*\nWAW01A - Stawki 2, 00-193 Warszawa"
    assert_includes message_text, "• 1x Filter Coffee"
  end

  test "includes home delivery option and stripe shipping address in telegram notification" do
    order = build_submitted_order(
      delivery_method: "home_delivery",
      delivery_details: {}
    )

    sent_messages = capture_telegram_messages do
      Notifications::OrderCreatedJob.perform_now(order)
    end

    assert_equal 1, sent_messages.size
    message_text, _options = sent_messages.first
    assert_includes message_text, "*Delivery Option*\nHome delivery"
    assert_includes message_text, "*Delivery Address*\nMarszalkowska 10, Warszawa, 00-001, PL"
  end

  private

  def capture_telegram_messages(&block)
    messages = []
    singleton = Telegrama.singleton_class
    original_send_message = Telegrama.method(:send_message)
    singleton.define_method(:send_message) do |text, **options|
      messages << [ text, options ]
    end
    block.call
    messages
  ensure
    singleton.define_method(:send_message, original_send_message) if original_send_message
  end

  def build_submitted_order(delivery_method:, delivery_details:)
    product = Product.unscoped.create!(
      account: @account,
      name: "Filter Coffee",
      stripe_product_id: "prod_notify_#{SecureRandom.hex(4)}",
      stripe_product: {
        id: "prod_notify",
        name: "Filter Coffee",
        active: true,
        images: []
      }
    )

    price = product.prices.create!(
      stripe_price_id: "price_notify_#{SecureRandom.hex(4)}",
      stripe_price: {
        id: "price_notify",
        unit_amount: 4000,
        currency: "pln",
        active: true,
        type: "one_time"
      }
    )

    order = @account.orders.create!(
      user_id: SecureRandom.uuid,
      status: :submitted,
      delivery_method:,
      delivery_details:,
      subtotal_amount: 4000,
      total_amount: 4000,
      checkout_session: {
        id: "cs_test_notify",
        amount_total: 4000,
        total_details: {
          amount_shipping: 0,
          amount_tax: 0,
          amount_discount: 0
        },
        customer_details: {
          name: "Jan Kowalski",
          email: "jan@example.com",
          phone: "+48123456789"
        },
        collected_information: {
          shipping_details: {
            name: "Jan Kowalski",
            address: {
              line1: "Marszalkowska 10",
              city: "Warszawa",
              postal_code: "00-001",
              country: "PL"
            }
          }
        }
      }
    )

    order.order_items.create!(price:, quantity: 1, unit_amount: 4000, total_amount: 4000)
    order
  end
end
