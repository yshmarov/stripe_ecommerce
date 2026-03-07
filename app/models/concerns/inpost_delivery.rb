module InpostDelivery
  extend ActiveSupport::Concern

  included do
    validates :inpost_parcel_id, presence: true, if: :inpost_delivery?
    validates :inpost_pickup_point, presence: true, if: :inpost_delivery?
  end

  def inpost_delivery?
    delivery_method == 'inpost'
  end

  def inpost_tracking_url
    return nil unless inpost_parcel_id.present?
    "https://inpost.pl/sledzenie-przesylek?number=#{inpost_parcel_id}"
  end

  def inpost_pickup_point_name
    return nil unless inpost_pickup_point.present?
    inpost_pickup_point['name']
  end

  def inpost_pickup_point_address
    return nil unless inpost_pickup_point.present?
    "#{inpost_pickup_point['address']}, #{inpost_pickup_point['city']}"
  end
end
