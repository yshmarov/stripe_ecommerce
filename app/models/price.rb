class Price < ApplicationRecord
  belongs_to :product

  validates :stripe_price_id, presence: true, uniqueness: true
  validates :stripe_price, presence: true

  scope :sellable, -> { where("stripe_price->>'active' = ?", true).where("stripe_price->>'recurring' IS NULL") }
  default_scope { sellable }
end
