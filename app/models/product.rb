class Product < ApplicationRecord
  validates :name, presence: true
  validates :stripe_product_id, presence: true, uniqueness: true
  validates :stripe_product, presence: true

  has_many :prices, dependent: :destroy

  scope :sellable, -> { joins(:prices).merge(Price.sellable).where.not(stripe_product: nil).where("(stripe_product->>'active')::boolean = true") }

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

  def image_url
    stripe_product["images"].first
  end

  def default_price
    default_price_id = stripe_product&.dig("default_price", "id")
    prices.detect { |price| price.stripe_price_id == default_price_id } || prices.first
  end

  def default_unit_amount
    default_price.stripe_price["unit_amount"]
  end

  def default_currency
    default_price.stripe_price["currency"]
  end
end
