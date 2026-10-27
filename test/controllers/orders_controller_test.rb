require "test_helper"
require "ostruct"

class OrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:one)
  end

  test "index" do
    get orders_url
    assert_response :success
  end

  test "show redirects when order does not belong to current guest" do
    @order = @account.orders.create!(user_id: SecureRandom.uuid, status: :draft)
    get order_url(@order)
    assert_redirected_to orders_url
  end

  test "draft order requires delivery selection before checkout button is enabled" do
    order = create_draft_order_with_item

    with_active_stripe_price do
      get order_url(order)
    end
    assert_response :success
    assert_select "input[name='order[delivery_method]'][value='home_delivery']"
    assert_select "input[name='order[delivery_method]'][value='inpost']"
    assert_select "form[action='#{order_checkout_index_path(order)}'] button[disabled='disabled']"
  end

  test "saving home_delivery enables checkout and clears previous inpost locker details" do
    order = create_draft_order_with_item
    order.update!(
      delivery_method: "inpost",
      delivery_details: {
        "point_name" => "WAW01A",
        "point_address" => "Stawki 2, 00-193 Warszawa"
      }
    )

    patch order_url(order), params: {
      order: {
        delivery_method: "home_delivery",
        delivery_details: {
          address: "Marszalkowska 10, Warszawa",
          point_name: "WAW01A",
          point_address: "Stawki 2, 00-193 Warszawa"
        }
      }
    }

    assert_redirected_to order_url(order)
    order.reload
    assert_equal "home_delivery", order.delivery_method
    assert_equal({ "address" => "Marszalkowska 10, Warszawa" }, order.delivery_details)

    with_active_stripe_price do
      follow_redirect!
    end
    assert_response :success
    assert_select "form[action='#{order_checkout_index_path(order)}'] button:not([disabled])"
  end

  test "saving inpost delivery stores parcel locker details on order" do
    order = create_draft_order_with_item

    patch order_url(order), params: {
      order: {
        delivery_method: "inpost",
        delivery_details: {
          point_name: "KRA01M",
          point_address: "Pawia 5, 31-154 Krakow",
          address: "Should be stripped"
        }
      }
    }

    assert_redirected_to order_url(order)
    order.reload
    assert_equal "inpost", order.delivery_method
    assert_equal(
      {
        "point_name" => "KRA01M",
        "point_address" => "Pawia 5, 31-154 Krakow"
      },
      order.delivery_details
    )
  end

  test "saving inpost delivery without locker details returns unprocessable_entity" do
    order = create_draft_order_with_item

    patch order_url(order), params: {
      order: {
        delivery_method: "inpost",
        delivery_details: {
          point_name: "",
          point_address: ""
        }
      }
    }

    assert_response :unprocessable_entity
    order.reload
    assert_nil order.delivery_method
  end

  test "renders inpost geowidget when token is configured" do
    order = create_draft_order_with_item
    previous_token = ENV["INPOST_GEOWIDGET_TOKEN"]
    ENV["INPOST_GEOWIDGET_TOKEN"] = "test_geowidget_token"

    with_active_stripe_price do
      get order_url(order)
    end
    assert_response :success
    assert_select "inpost-geowidget[token='test_geowidget_token'][config='parcelCollect']"
  ensure
    ENV["INPOST_GEOWIDGET_TOKEN"] = previous_token
  end

  test "update rating on completed order" do
    order = create_draft_order_with_item
    order.update!(status: :done)

    patch order_url(order), params: { order: { rating: 5 } }
    assert_redirected_to order_url(order)
    assert_equal 5, order.reload.rating
  end

  private

  def with_active_stripe_price(&block)
    fake_price = OpenStruct.new(active: true, product: OpenStruct.new(active: true))
    singleton = Stripe::Price.singleton_class
    original_retrieve = Stripe::Price.method(:retrieve)
    singleton.define_method(:retrieve) { |*_args| fake_price }
    block.call
  ensure
    singleton.define_method(:retrieve, original_retrieve) if original_retrieve
  end

  def create_draft_order_with_item
    price = create_sellable_price
    post add_to_cart_url(price)
    Order.order(:created_at).last
  end

  def create_sellable_price
    product = Product.unscoped.create!(
      account: @account,
      name: "Test Coffee",
      stripe_product_id: "prod_test_#{SecureRandom.hex(4)}",
      stripe_product: {
        id: "prod_test",
        name: "Test Espresso Beans",
        active: true,
        images: []
      }
    )

    product.prices.create!(
      stripe_price_id: "price_test_#{SecureRandom.hex(4)}",
      stripe_price: {
        id: "price_test",
        unit_amount: 2500,
        currency: "pln",
        active: true,
        type: "one_time"
      }
    )
  end
end
