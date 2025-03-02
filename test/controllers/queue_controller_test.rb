require "test_helper"

class QueueControllerTest < ActionDispatch::IntegrationTest
  test "index" do
    get queue_url
    assert_response :not_found

    Setting.public_order_queue = true
    get queue_url
    assert_response :success
  end
end
