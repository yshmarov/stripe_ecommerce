class Price < ApplicationRecord
  belongs_to :product

  validates :stripe_price_id, presence: true, uniqueness: true
  validates :stripe_price, presence: true
end
