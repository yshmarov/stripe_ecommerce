require "test_helper"

class CheckoutControllerTest < ActionDispatch::IntegrationTest
  setup do
    Setting.default_currency = "usd"
  end

  test "requires delivery selection before checkout" do
    price = prices(:one)
    post add_to_cart_url(price)
    order = Order.last

    post order_checkout_index_url(order)

    assert_redirected_to order_url(order)
    assert_equal I18n.t("orders.update.delivery_required"), flash[:notice]
  end

  test "creates checkout session with selected InPost metadata" do
    price = prices(:one)
    post add_to_cart_url(price)
    order = Order.last
    order.update!(
      delivery_method: "inpost",
      delivery_details: {
        point_name: "KRA302",
        point_address: "ul. Testowa 1, Krakow"
      }
    )

    Stripe::ShippingRate.stubs(:list).returns(OpenStruct.new(data: []))
    Stripe::Checkout::Session.expects(:create).with do |params|
      params[:metadata] == {
        delivery_method: "inpost",
        inpost_point_name: "KRA302",
        inpost_point_address: "ul. Testowa 1, Krakow"
      } && params[:shipping_address_collection].nil?
    end.returns(OpenStruct.new(url: "https://checkout.stripe.test/session"))

    post order_checkout_index_url(order)

    assert_redirected_to "https://checkout.stripe.test/session"
  end
end
