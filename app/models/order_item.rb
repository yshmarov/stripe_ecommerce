class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :order_id, uniqueness: { scope: :product_id }
  validates :quantity, presence: true
  validates :quantity, numericality: { greater_than: 0 }

  extend FriendlyId
  friendly_id :generate_random_slug, use: [ :finders, :slugged ]

  def calculate_total_price
    update(price: product.default_price, total_price: quantity * product.default_price)
    order.calculate_total_price
  end
end
