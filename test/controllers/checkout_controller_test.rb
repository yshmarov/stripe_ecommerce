require "test_helper"
require "ostruct"

class CheckoutControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:one)
  end

  test "redirects back to order when delivery method has not been selected" do
    order = create_draft_order_with_item

    post order_checkout_index_url(order)

    assert_redirected_to order_url(order)
    assert_equal I18n.t("orders.delivery.required"), flash[:alert]
  end

  test "creates stripe checkout session with shipping collection for home_delivery" do
    order = create_draft_order_with_item
    order.update!(
      delivery_method: "home_delivery",
      delivery_details: { "address" => "Nowy Swiat 15, Warszawa" }
    )

    captured_params = nil
    with_stubbed_stripe_checkout(->(params) { captured_params = params }) do
      post order_checkout_index_url(order)
    end

    assert_redirected_to "https://checkout.stripe.com/c/pay/cs_test_123"
    assert_equal(
      {
        delivery_method: "home_delivery",
        delivery_address: "Nowy Swiat 15, Warszawa"
      },
      captured_params[:metadata]
    )
    assert_equal({ allowed_countries: Setting.shipping_countries }, captured_params[:shipping_address_collection])
    assert_equal [ { shipping_rate: "shr_test_123" } ], captured_params[:shipping_options]
  end

  test "creates stripe checkout session with inpost metadata and without shipping address collection" do
    order = create_draft_order_with_item
    order.update!(
      delivery_method: "inpost",
      delivery_details: {
        "point_name" => "WAW22M",
        "point_address" => "Marszalkowska 99, 00-693 Warszawa"
      }
    )

    captured_params = nil
    with_stubbed_stripe_checkout(->(params) { captured_params = params }) do
      post order_checkout_index_url(order)
    end

    assert_redirected_to "https://checkout.stripe.com/c/pay/cs_test_123"
    assert_equal(
      {
        delivery_method: "inpost",
        inpost_point_name: "WAW22M",
        inpost_point_address: "Marszalkowska 99, 00-693 Warszawa"
      },
      captured_params[:metadata]
    )
    assert_nil captured_params[:shipping_address_collection]
    assert_nil captured_params[:shipping_options]
  end

  private

  def create_draft_order_with_item
    product = Product.unscoped.create!(
      account: @account,
      name: "Test Coffee",
      stripe_product_id: "prod_checkout_#{SecureRandom.hex(4)}",
      stripe_product: {
        id: "prod_checkout",
        name: "Checkout Coffee",
        active: true,
        images: []
      }
    )

    price = product.prices.create!(
      stripe_price_id: "price_checkout_#{SecureRandom.hex(4)}",
      stripe_price: {
        id: "price_checkout",
        unit_amount: 3200,
        currency: "pln",
        active: true,
        type: "one_time"
      }
    )

    post add_to_cart_url(price)
    Order.order(:created_at).last
  end

  def with_stubbed_stripe_checkout(capture_callback, &block)
    fake_session = OpenStruct.new(url: "https://checkout.stripe.com/c/pay/cs_test_123")
    fake_rates = OpenStruct.new(data: [ OpenStruct.new(id: "shr_test_123") ])

    session_singleton = Stripe::Checkout::Session.singleton_class
    rate_singleton = Stripe::ShippingRate.singleton_class
    original_create = Stripe::Checkout::Session.method(:create)
    original_list = Stripe::ShippingRate.method(:list)

    session_singleton.define_method(:create) do |params|
      capture_callback.call(params)
      fake_session
    end
    rate_singleton.define_method(:list) { |*_args| fake_rates }

    block.call
  ensure
    session_singleton.define_method(:create, original_create) if original_create
    rate_singleton.define_method(:list, original_list) if original_list
  end
end
