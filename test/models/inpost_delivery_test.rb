require "test_helper"

class InpostDeliveryTest < ActiveSupport::TestCase
  setup do
    @account = accounts(:one)
    @order = @account.orders.create!(
      status: Order.statuses[:draft],
      user_id: 1,
      delivery_method: 'inpost',
      inpost_parcel_id: 'INPOST123456789',
      inpost_pickup_point: {
        'name' => 'InPost Point Warszawa',
        'address' => 'ul. Przykładowa 1',
        'city' => 'Warszawa'
      }
    )
  end

  test "inpost_delivery? returns true for inpost delivery method" do
    assert @order.inpost_delivery?
  end

  test "inpost_delivery? returns false for other delivery methods" do
    @order.update!(delivery_method: 'standard')
    refute @order.inpost_delivery?
  end

  test "inpost_tracking_url returns correct URL" do
    assert_equal "https://inpost.pl/sledzenie-przesylek?number=INPOST123456789", @order.inpost_tracking_url
  end

  test "inpost_tracking_url returns nil without parcel id" do
    @order.update!(inpost_parcel_id: nil)
    assert_nil @order.inpost_tracking_url
  end

  test "inpost_pickup_point_name returns point name" do
    assert_equal "InPost Point Warszawa", @order.inpost_pickup_point_name
  end

  test "inpost_pickup_point_address returns formatted address" do
    assert_equal "ul. Przykładowa 1, Warszawa", @order.inpost_pickup_point_address
  end

  test "validates presence of inpost_parcel_id for inpost delivery" do
    order = @account.orders.create!(
      status: Order.statuses[:draft],
      user_id: 1,
      delivery_method: 'inpost',
      inpost_parcel_id: nil
    )
    refute order.valid?
    assert_includes order.errors[:inpost_parcel_id], "can't be blank"
  end

  test "validates presence of inpost_pickup_point for inpost delivery" do
    order = @account.orders.create!(
      status: Order.statuses[:draft],
      user_id: 1,
      delivery_method: 'inpost',
      inpost_parcel_id: 'INPOST123456789',
      inpost_pickup_point: nil
    )
    refute order.valid?
    assert_includes order.errors[:inpost_pickup_point], "can't be blank"
  end
end
