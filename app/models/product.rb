class Product < ApplicationRecord
  validates :name, presence: true
  validates :stripe_product_id, presence: true, uniqueness: true
  validates :stripe_product, presence: true

  has_many :prices, dependent: :destroy
  has_many :order_items, dependent: :restrict_with_error
  has_many :orders, through: :order_items

  scope :sellable, -> { joins(:prices).merge(Price.sellable).where.not(stripe_product: nil).where("stripe_product->>'active' = ?", true) }

  default_scope { sellable }

  scope :search, ->(query) {
    if ActiveRecord::Base.connection.adapter_name.downcase == "postgresql"
      where("name ILIKE ?", "%#{query}%")
    else
      where("LOWER(name) LIKE ?", "%#{query.downcase}%")
    end
  }

  extend FriendlyId
  friendly_id :name, use: [ :finders, :slugged ]

  def items_in_cart(current_order)
    order_items.find_by(order: current_order)&.quantity
  end

  def image_url
    stripe_product["images"].first
  end

  def default_price
    prices.first
  end

  def default_unit_amount
    default_price.stripe_price["unit_amount"]
  end

  def default_currency
    default_price.stripe_price["currency"]
  end
end
