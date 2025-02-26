class Product < ApplicationRecord
  validates :name, presence: true
  validates :stripe_product, presence: true

  has_many :order_items, dependent: :restrict_with_error
  has_many :orders, through: :order_items

  scope :with_default_price, -> { where.not(stripe_product: nil).where("stripe_product->>'default_price' IS NOT NULL").where("stripe_product->'default_price'->>'recurring' IS NULL") }
  default_scope { with_default_price }

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
    stripe_product["default_price"]["unit_amount"]
  end

  def default_currency
    stripe_product["default_price"]["currency"]
  end
end
