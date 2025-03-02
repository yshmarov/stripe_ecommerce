require "test_helper"

class OrderItemsControllerTest < ActionDispatch::IntegrationTest
  test "update" do
    product = products(:monster_classic)
    price = product.default_price
    post add_to_cart_path(price)

    order = Order.last
    assert_equal 1, order.order_items.count
    assert_equal 1, order.order_items_quantity

    # can edit draft order items
    put order_order_item_url(order, order.order_items.first), params: { order_item: { quantity: 20 } }
    assert_redirected_to order_path(order)
    assert_equal 1, order.order_items.count
    assert_equal 20, order.reload.order_items_quantity

    # can't edit submitted order items
    order.submitted!
    put order_order_item_url(order, order.order_items.first), params: { order_item: { quantity: 21 } }
    assert_response :not_found
  end

  test "destroy" do
    product = products(:monster_classic)
    price = product.default_price
    post add_to_cart_path(price)
    post add_to_cart_path(price)

    order = Order.last
    assert_equal 1, order.order_items.count
    assert_equal 2, order.order_items_quantity
    assert_equal 1198, order.total_amount

    delete order_order_item_url(order, order.order_items.first)
    assert_redirected_to order_path(order)
    assert_equal 0, order.order_items.count
    assert_equal 0, order.reload.order_items_quantity
    assert_equal 0, order.total_amount
  end
end
