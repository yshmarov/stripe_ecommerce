class Account < ApplicationRecord
  validates :stripe_account_id, presence: true
  validates :stripe_account, presence: true

  has_many :orders, dependent: :destroy
  has_many :products, dependent: :destroy
  has_many :prices, through: :products

  def stripe_account_object
    @stripe_account_object ||= Stripe::Account.construct_from(stripe_account)
  end

  def stripe_logo_url
    logo_id = stripe_account_object.settings.branding.logo
    return nil unless logo_id.present?

    Rails.cache.fetch("stripe_logo_url_#{logo_id}", expires_in: 1.hour) do
      file = Stripe::File.retrieve(logo_id)
      file.links.first.url
    rescue Stripe::InvalidRequestError
      nil
    end
  end

  def stripe_business_profile
    stripe_account_object.try(:business_profile)
  end

  def stripe_business_profile_name
    stripe_business_profile&.name
  end

  def stripe_business_profile_support_address
    stripe_business_profile&.support_address&.values&.compact&.join(", ")
  end

  def stripe_business_profile_support_email
    stripe_business_profile&.support_email
  end

  def stripe_business_profile_support_phone
    stripe_business_profile&.support_phone
  end
end
