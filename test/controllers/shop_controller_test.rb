require "test_helper"

class ShopControllerTest < ActionDispatch::IntegrationTest
  test "add to cart" do
    get products_path
    assert_response :success

    product = products(:monster_classic)
    price = product.default_price
    assert_difference "Order.count", 1 do
      assert_difference "OrderItem.count", 1 do
        post add_to_cart_path(price)
      end
    end
    assert_redirected_to products_path
    assert_equal "#{product.name} added to cart", flash[:notice]

    order = Order.last
    assert_equal product, order.products.first
    assert_equal 1, order.order_items.first.quantity
    assert_equal price.stripe_price_object.unit_amount, order.total_amount
    assert_equal price.stripe_price_object.unit_amount, order.order_items.first.total_amount
    assert_equal price.stripe_price_object.unit_amount, order.order_items.first.unit_amount

    product2 = products(:rafaello)
    price2 = product2.default_price
    post add_to_cart_path(price2)
    assert_redirected_to products_path
    assert_equal "#{product2.name} added to cart", flash[:notice]
    assert_equal 2, order.reload.order_items_quantity
    assert_equal 2, order.order_items.count

    total = price.stripe_price_object.unit_amount + price2.stripe_price_object.unit_amount
    assert_equal total, order.total_amount
    assert_equal price.stripe_price_object.unit_amount, order.order_items.first.total_amount
    assert_equal price.stripe_price_object.unit_amount, order.order_items.first.unit_amount
    assert_equal price2.stripe_price_object.unit_amount, order.order_items.second.unit_amount
    assert_equal price2.stripe_price_object.unit_amount, order.order_items.second.total_amount

    post add_to_cart_path(price2)
    order.reload
    assert_equal 3, order.order_items_quantity
    assert_equal 2, order.order_items.count

    total = price.stripe_price_object.unit_amount + (price2.stripe_price_object.unit_amount * 2)
    assert_equal total, order.total_amount
    assert_equal price.stripe_price_object.unit_amount, order.order_items.first.total_amount
    assert_equal price.stripe_price_object.unit_amount, order.order_items.first.unit_amount
    assert_equal price2.stripe_price_object.unit_amount, order.order_items.second.unit_amount
    assert_equal price2.stripe_price_object.unit_amount * 2, order.order_items.second.total_amount
  end
end
