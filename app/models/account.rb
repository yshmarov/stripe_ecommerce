class Account < ApplicationRecord
  validates :stripe_account_id, presence: true
  validates :stripe_account, presence: true

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
end
