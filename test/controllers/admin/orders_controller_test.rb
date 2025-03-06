require "test_helper"

class Admin::OrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @headers = { Authorization: ActionController::HttpAuthentication::Basic.encode_credentials(
      SecuredController::USERNAME, SecuredController::PASSWORD
    ) }
    @account = accounts(:one)
  end

  test "index" do
    get admin_orders_url
    assert_response :unauthorized

    get admin_orders_url, headers: @headers
    assert_response :success
  end

  test "show" do
    order = @account.orders.create!(status: Order.statuses[:submitted], user_id: 1)
    get admin_order_url(order), headers: @headers
    assert_response :success
  end

  test "update" do
    order = @account.orders.create!(status: Order.statuses[:submitted], user_id: 1)
    patch admin_order_url(order), headers: @headers

    assert_redirected_to admin_order_url(order)
    assert_equal "processing", order.reload.status
  end
end
