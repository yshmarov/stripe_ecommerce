class Price < ApplicationRecord
  belongs_to :product

  has_many :order_items, dependent: :restrict_with_error
  has_many :orders, through: :order_items

  validates :stripe_price_id, presence: true, uniqueness: true
  validates :stripe_price, presence: true

  scope :sellable, -> { where("stripe_price->>'active' = ?", true).where("stripe_price->>'recurring' IS NULL") }
  default_scope { sellable }

  def items_in_cart(current_order)
    order_items.find_by(order: current_order)&.quantity
  end
end
