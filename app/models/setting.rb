# RailsSettings Model
class Setting < RailsSettings::Base
  cache_prefix { "v1" }

  scope :general do
    field :search, default: true, type: :boolean, help_text: "Enable search"
    field :public_order_queue, default: false, type: :boolean, help_text: "Like McDonalds order progress screen"
    field :app_name, default: "Snack Bar by Yaro", type: :string, validates: { presence: true, length: { in: 2..20 } }
    field :logo_url, type: :string, default: "https://superails.com/logo.png"
    field :description, default: "Self checkout snack bar", type: :text, validates: { presence: true, length: { in: 2..200 } }
  end

  BILLING_ADDRESS_COLLECTION_OPTIONS = %w[auto required]

  scope :checkout do
    field :allow_promotion_codes, default: false, type: :boolean
    field :phone_number_collection, default: false, type: :boolean
    field :billing_address_collection, default: "auto", type: :string, validates: { presence: true, inclusion: { in: BILLING_ADDRESS_COLLECTION_OPTIONS } }, option_values: BILLING_ADDRESS_COLLECTION_OPTIONS
  end

  scope :legal do
    field :address, default: "ul. Kowalska 123, 00-000 Warszawa", type: :string, validates: { presence: true, length: { in: 2..200 } }
    field :email, default: "info@snackbarbyyaro.com", type: :string, validates: { presence: true, length: { in: 2..100 } }
    field :phone, default: "+48 123 456 789", type: :string, validates: { presence: true, length: { in: 2..20 } }
    field :trade_name, default: "Snack Bar By Yaro LLC", type: :string, validates: { presence: true, length: { in: 2..40 } }
    field :trade_vat_number, default: "PL1234567890", type: :string, validates: { presence: true, length: { in: 2..20 } }
    field :terms_of_service, type: :text
    field :privacy_policy, type: :text
    field :refund_policy, type: :text
  end

  scope :socials do
    field :instagram, default: "https://www.instagram.com/yaro_the_slav", type: :string
    field :twitter, default: "https://twitter.com/yarotheslav", type: :string
    field :tiktok, default: "", type: :string, help_text: "https://www.tiktok.com/@yaro_the_slav"
    field :linkedin, default: "", type: :string, help_text: "https://www.linkedin.com/in/yarotheslav"
    field :youtube, default: "", type: :string, help_text: "https://www.youtube.com/@yaro_the_slav"
    field :facebook, default: "", type: :string, help_text: "https://www.facebook.com/yarotheslav"
    field :pinterest, default: "", type: :string, help_text: "https://www.pinterest.com/yarotheslav"
    field :twitch, default: "", type: :string, help_text: "https://www.twitch.tv/yarotheslav"
    field :discord, default: "", type: :string, help_text: "https://discord.gg/yarotheslav"
    field :telegram, default: "", type: :string, help_text: "https://t.me/yarotheslav"
    field :whatsapp, default: "", type: :string, help_text: "https://wa.me/yarotheslav"
  end

  def self.get_scope(scope_name)
    defined_fields
      .select { |field| field[:scope] == scope_name }
      .each_with_object({}) { |field, hash| hash[field[:key]] = send(field[:key]) }
  end
end
