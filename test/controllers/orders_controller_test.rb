require "test_helper"

class OrdersControllerTest < ActionDispatch::IntegrationTest
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
end
