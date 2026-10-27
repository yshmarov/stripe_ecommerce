class Order < ApplicationRecord
  DELIVERY_METHODS = %w[home_delivery inpost].freeze

  enum :status, { draft: "draft",
                  submitted: "submitted",
                  processing: "processing",
                  delivery: "delivery",
                  done: "done" }

  belongs_to :account

  has_many :order_items, dependent: :destroy
  has_many :prices, through: :order_items

  before_validation :normalize_delivery_fields

  def products
    prices.map(&:product).uniq
  end

  def currency
    prices.first.stripe_price_object.currency
  end

  validates :user_id, presence: true
  validates :status, presence: true
  validates :rating, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }, allow_blank: true
  validates :delivery_method, inclusion: { in: DELIVERY_METHODS }, allow_blank: true
  validate :validate_delivery_details

  scope :queued, -> { where(status: %w[submitted processing delivery]) }

  def next_status
    Order.statuses.keys.split(status).last.first
  end

  def statuses_for_display
    return [ status ] if %w[draft].include?(status)

    self.class.statuses.reject { |k, _v| %w[draft].include?(k) }.keys
  end

  after_update_commit do
    broadcast_refresh_to :orders
    broadcast_refresh
  end

  def calculate_subtotal_amount
    update(
      subtotal_amount: order_items.sum(&:total_amount),
      order_items_quantity: order_items.sum(&:quantity)
    )
    calculate_total_amount
  end

  def calculate_total_amount
    total_amount = 0
    return total_amount if draft?
    return total_amount if stripe_checkout_session_object.nil?

    total_amount = subtotal_amount +
      stripe_checkout_session_object.total_details.amount_shipping +
      stripe_checkout_session_object.total_details.amount_tax -
      stripe_checkout_session_object.total_details.amount_discount

    update(
      total_amount: total_amount
    )

    total_amount
  end

  def stripe_checkout_session_object
    return nil if checkout_session.blank?

    Stripe::Checkout::Session.construct_from(checkout_session)
  end

  def home_delivery?
    delivery_method == "home_delivery"
  end

  def inpost_delivery?
    delivery_method == "inpost"
  end

  def delivery_address
    delivery_details["address"].presence
  end

  def delivery_point_name
    delivery_details["point_name"].presence
  end

  def delivery_point_address
    delivery_details["point_address"].presence
  end

  def inpost_point_summary
    return nil unless inpost_delivery?

    [ delivery_point_name, delivery_point_address ].compact_blank.join(" - ").presence
  end

  def stripe_shipping_address
    stripe_checkout_session_object
      &.collected_information
      &.shipping_details
      &.address
      &.values
      &.compact_blank
      &.join(", ")
      .presence
  end

  def delivery_method_label
    return nil if delivery_method.blank?

    I18n.t("activerecord.attributes.order.delivery_methods.#{delivery_method}")
  end

  def delivery_location_summary
    if inpost_delivery?
      inpost_point_summary
    elsif home_delivery?
      delivery_address.presence || stripe_shipping_address
    else
      stripe_shipping_address
    end
  end

  def delivery_summary
    return nil if delivery_method.blank?

    if inpost_delivery?
      [ delivery_method_label, inpost_point_summary ].compact_blank.join(": ").presence
    elsif home_delivery?
      [ delivery_method_label, delivery_address ].compact_blank.join(": ").presence
    end
  end

  def delivery_selection_complete?
    home_delivery? || (inpost_delivery? && delivery_point_name.present? && delivery_point_address.present?)
  end

  def checkout_metadata
    {
      delivery_method:,
      delivery_address:,
      inpost_point_name: delivery_point_name,
      inpost_point_address: delivery_point_address
    }.compact_blank
  end

  def validate_order_items
    return unless draft?
    order_items.each do |order_item|
      stripe_price_id = order_item.price.stripe_price_id
      stripe_price = Stripe::Price.retrieve({ id: stripe_price_id, expand: [ "product" ] })
      next if stripe_price.present? && stripe_price.active && stripe_price.product.active

      order_items.delete(order_item)
    end
  end

  private

  def normalize_delivery_fields
    if delivery_method.present?
      normalized_method = delivery_method.to_s.strip.underscore
      normalized_method = "inpost" if normalized_method == "in_post"
      self.delivery_method = normalized_method
    end

    raw_details = delivery_details.is_a?(Hash) ? delivery_details : {}
    cleaned_details = raw_details.to_h.stringify_keys.transform_values { |value| value.to_s.strip }.reject { |_, value| value.blank? }

    self.delivery_details =
      case delivery_method
      when "home_delivery"
        cleaned_details.slice("address")
      when "inpost"
        cleaned_details.slice("point_name", "point_address")
      else
        cleaned_details
      end
  end

  def validate_delivery_details
    return unless inpost_delivery?

    errors.add(:base, I18n.t("activerecord.errors.models.order.attributes.delivery_details.inpost_point_blank")) if delivery_point_name.blank?
    errors.add(:base, I18n.t("activerecord.errors.models.order.attributes.delivery_details.inpost_address_blank")) if delivery_point_address.blank?
  end
end
