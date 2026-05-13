require "test_helper"

class OrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    Setting.default_currency = "usd"
  end

  test "index" do
    get orders_url
    assert_response :success
  end

  test "update" do
    ActionDispatch::TestRequest.create.cookie_jar.tap do |cookie_jar|
      cookie_jar.signed[:guest_id] = "123"
      cookies[:guest_id] = cookie_jar[:guest_id]
    end

    product = products(:monster_classic)
    post add_to_cart_url(product.id)
    order = Order.last

    patch order_url(order), params: { order: { status: "submitted" } }
    assert_equal "draft", order.reload.status
    assert_redirected_to order_url(order)
    assert_equal "Order is not completed yet", flash[:notice]

    patch order_url(order), params: { order: { status: "delivery", rating: 5 } }
    assert_nil order.reload.rating

    order.done!
    patch order_url(order), params: { order: { status: "delivery", rating: 4 } }
    assert_equal "done", order.reload.status
    assert_not_nil order.reload.rating

    patch order_url(order), params: { order: { rating: 5 } }
    assert_equal 5, order.reload.rating
  end

  test "update delivery selection on draft order" do
    ActionDispatch::TestRequest.create.cookie_jar.tap do |cookie_jar|
      cookie_jar.signed[:guest_id] = "123"
      cookies[:guest_id] = cookie_jar[:guest_id]
    end

    price = prices(:one)
    post add_to_cart_url(price)
    order = Order.last

    patch order_url(order), params: {
      order: {
        delivery_method: "inpost",
        delivery_details: {
          point_name: "KRA302",
          point_address: "ul. Testowa 1, Krakow"
        }
      }
    }

    assert_redirected_to order_url(order)
    assert_equal "inpost", order.reload.delivery_method
    assert_equal "KRA302", order.inpost_point_name
    assert_equal "ul. Testowa 1, Krakow", order.inpost_point_address
    assert_equal I18n.t("orders.update.delivery_saved"), flash[:notice]
  end
end
