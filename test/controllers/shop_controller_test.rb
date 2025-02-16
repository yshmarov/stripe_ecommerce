require "test_helper"

class ShopControllerTest < ActionDispatch::IntegrationTest
  test "add to cart" do
    get products_path
    assert_response :success

    product = products(:monster_classic)
    assert_difference "Order.count", 1 do
      assert_difference "OrderItem.count", 1 do
        post add_to_cart_path(product.id)
      end
    end
    assert_redirected_to products_path
    assert_equal "#{product.name} added to cart", flash[:notice]

    order = Order.last
    assert_equal product, order.products.first
    assert_equal 1, order.order_items.first.quantity
    assert_equal "To go", order.delivery_details
    assert_equal 599, order.total_price
    assert_equal 599, order.order_items.first.total_price
    assert_equal 599, order.order_items.first.price

    product2 = products(:rafaello)
    post add_to_cart_path(product2.id)
    assert_redirected_to products_path
    assert_equal "#{product2.name} added to cart", flash[:notice]
    assert_equal 2, order.reload.order_items_quantity
    assert_equal 2, order.order_items.count

    assert_equal 698, order.total_price
    assert_equal 599, order.order_items.first.total_price
    assert_equal 599, order.order_items.first.price
    assert_equal 99, order.order_items.second.price
    assert_equal 99, order.order_items.second.total_price

    post add_to_cart_path(product2.id)
    order.reload
    assert_equal 3, order.order_items_quantity
    assert_equal 2, order.order_items.count

    assert_equal 797, order.total_price
    assert_equal 599, order.order_items.first.total_price
    assert_equal 599, order.order_items.first.price
    assert_equal 99, order.order_items.second.price
    assert_equal 198, order.order_items.second.total_price
  end

  test "search products" do
    get search_products_path, params: { query: "monster" }
    assert_response :success
    assert_match "Monster", response.body
    assert_no_match "Rafaello", response.body
  end
end
