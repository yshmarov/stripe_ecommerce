class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :price

  validates :order_id, uniqueness: { scope: :price_id }
  validates :quantity, presence: true
  validates :quantity, numericality: { greater_than: 0 }

  def calculate_total_amount
    update(unit_amount: price.stripe_price_object.unit_amount, total_amount: quantity * price.stripe_price_object.unit_amount)
    order.calculate_subtotal_amount
  end
end
