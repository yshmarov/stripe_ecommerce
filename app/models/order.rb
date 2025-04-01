class Order < ApplicationRecord
  enum :status, { draft: "draft",
                  submitted: "submitted",
                  processing: "processing",
                  delivery: "delivery",
                  done: "done" }

  belongs_to :account

  has_many :order_items, dependent: :destroy
  has_many :prices, through: :order_items

  def products
    prices.map(&:product).uniq
  end

  def currency
    prices.first.stripe_price_object.currency
  end

  validates :user_id, presence: true
  validates :status, presence: true
  validates :rating, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }, allow_blank: true

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

  def calculate_total_amount
    update(
      total_amount: order_items.sum(&:total_amount),
      order_items_quantity: order_items.sum(&:quantity)
    )
  end

  def stripe_checkout_session_object
    Stripe::Checkout::Session.construct_from(checkout_session)
  end
end
