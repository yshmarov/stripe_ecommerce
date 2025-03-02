class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :order_id, uniqueness: { scope: :product_id }
  validates :quantity, presence: true
  validates :quantity, numericality: { greater_than: 0 }

  extend FriendlyId
  friendly_id :generate_random_slug, use: [ :finders, :slugged ]

  def calculate_total_price
    update(price: product.default_unit_amount, total_price: quantity * product.default_unit_amount)
    order.calculate_total_price
  end
end
