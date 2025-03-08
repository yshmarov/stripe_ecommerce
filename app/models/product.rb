class Product < ApplicationRecord
  validates :name, presence: true
  validates :stripe_product_id, presence: true, uniqueness: true
  validates :stripe_product, presence: true

  belongs_to :account

  has_many :prices, dependent: :destroy

  scope :sellable, -> { joins(:prices).merge(Price.sellable).where.not(stripe_product: nil).where("(stripe_product->>'active')::boolean = true") }

  default_scope { sellable }

  after_save_commit do
    account.regenerate_sitemap
  end

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
    stripe_product_object.images.first
  end

  def default_price
    default_price_id = if stripe_product_object.default_price.nil?
      nil
    elsif stripe_product_object.default_price.is_a?(String)
      stripe_product_object.default_price
    else
      stripe_product_object.default_price.id
    end

    if default_price_id.nil?
      prices.first
    else
      prices.detect { |price| price.stripe_price_id == default_price_id } || prices.first
    end
  end

  def default_unit_amount
    default_price.stripe_price_object.unit_amount
  end

  def default_currency
    default_price.stripe_price_object.currency
  end

  def stripe_product_object
    Stripe::Product.construct_from(stripe_product)
  end
end
