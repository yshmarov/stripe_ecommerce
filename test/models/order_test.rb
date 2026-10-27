require "test_helper"

class OrderTest < ActiveSupport::TestCase
  setup do
    @account = accounts(:one)
  end

  test "home delivery is complete with or without an optional draft address" do
    order = @account.orders.create!(
      user_id: "user_1",
      delivery_method: "home_delivery"
    )

    assert_predicate order, :home_delivery?
    assert_predicate order, :delivery_selection_complete?
    assert_equal "Home delivery", order.delivery_summary

    order.update!(delivery_details: { address: "ul. Nowy Świat 10, 00-001 Warszawa" })
    assert_equal "ul. Nowy Świat 10, 00-001 Warszawa", order.delivery_address
    assert_equal "Home delivery: ul. Nowy Świat 10, 00-001 Warszawa", order.delivery_summary
  end

  test "inpost delivery normalizes method name and requires locker name and address" do
    order = @account.orders.new(
      user_id: "user_1",
      delivery_method: "inPost",
      delivery_details: { point_name: "WAW01A" }
    )

    assert_not order.valid?
    assert_equal "inpost", order.delivery_method
    assert_not order.delivery_selection_complete?
    assert_includes order.errors.full_messages, "InPost parcel locker address is required"

    order.delivery_details = {
      point_name: "WAW01A",
      point_address: "ul. Marszałkowska 1, 00-001 Warszawa"
    }

    assert_predicate order, :valid?
    assert_predicate order, :delivery_selection_complete?
    assert_equal "InPost: WAW01A - ul. Marszałkowska 1, 00-001 Warszawa", order.delivery_summary
  end

  test "switching between inpost and home_delivery clears stale method-specific details" do
    order = @account.orders.create!(
      user_id: "user_1",
      delivery_method: "inpost",
      delivery_details: {
        point_name: "WAW01A",
        point_address: "ul. Marszałkowska 1, 00-001 Warszawa"
      }
    )

    order.update!(
      delivery_method: "home_delivery",
      delivery_details: {
        point_name: "WAW01A",
        point_address: "ul. Marszałkowska 1, 00-001 Warszawa",
        address: "ul. Złota 44, Warszawa"
      }
    )

    assert_nil order.delivery_point_name
    assert_nil order.delivery_point_address
    assert_equal({ "address" => "ul. Złota 44, Warszawa" }, order.delivery_details)
  end
end
