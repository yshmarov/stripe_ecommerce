# RailsSettings Model
class Setting < RailsSettings::Base
  cache_prefix { "v1" }

  CURRENCY_OPTIONS = %w[usd eur pln]

  scope :general do
    # field :brand_color, default: "#000000", type: :string, help_text: "Hex color code", foo: "bar"
    field :store_name, default: "Warszawa Books", type: :string, validates: { presence: true, length: { in: 2..20 } }
    # field :logo_url, default: "", type: :string, help_text: "https://www.warszawabooks.pl/logo.png"
    field :default_currency, default: "usd", type: :string, validates: { presence: true, inclusion: { in: CURRENCY_OPTIONS } }, option_values: CURRENCY_OPTIONS
    field :default_language, default: "en", type: :string, validates: { presence: true, inclusion: { in: I18n.available_locales.map(&:to_s) } }, option_values: I18n.available_locales.map(&:to_s)
    field :search, default: true, type: :boolean
    field :public_order_queue, default: false, type: :boolean
    field :description, default: "Best world literature in Ukrainian language", type: :text, validates: { presence: true, length: { in: 2..160 } }
  end

  BILLING_ADDRESS_COLLECTION_OPTIONS = %w[auto required]

  scope :checkout do
    field :allow_promotion_codes, default: false, type: :boolean
    field :phone_number_collection, default: true, type: :boolean
    field :billing_address_collection, default: "required", type: :string, validates: { presence: true, inclusion: { in: BILLING_ADDRESS_COLLECTION_OPTIONS } }, option_values: BILLING_ADDRESS_COLLECTION_OPTIONS
    field :shipping_countries, default: [ "FR", "PL" ], type: :array
    field :automatic_tax, default: false, type: :boolean
  end

  scope :legal do
    field :address, type: :string, validates: { length: { maximum: 200 } }, placeholder: "ul. Kowalska 123, 00-000 Warszawa"
    field :email, type: :string, validates: { length: { maximum: 100 } }, placeholder: "info@warszawabooks.pl"
    field :phone_number, type: :string, validates: { length: { maximum: 20 } }, placeholder: "+48 123 456 789"
    # field :trade_vat_number, type: :string, validates: { length: { in: 2..20 } }, placeholder: "PL1234567890"

    field :terms_of_service, type: :text, help_text: "Use Markdown syntax"
    field :privacy_policy, type: :text, help_text: "Use Markdown syntax"
    field :refund_policy, type: :text, help_text: "Use Markdown syntax"
  end

  scope :socials do
    field :instagram, default: "", type: :string, placeholder: "https://www.instagram.com/yaro_the_slav"
    field :twitter, default: "", type: :string, placeholder: "https://twitter.com/yarotheslav"
    field :tiktok, default: "", type: :string, placeholder: "https://www.tiktok.com/@yaro_the_slav"
    field :linkedin, default: "", type: :string, placeholder: "https://www.linkedin.com/in/yarotheslav"
    field :youtube, default: "", type: :string, placeholder: "https://www.youtube.com/@yaro_the_slav"
    field :facebook, default: "", type: :string, placeholder: "https://www.facebook.com/yarotheslav"
    field :pinterest, default: "", type: :string, placeholder: "https://www.pinterest.com/yarotheslav"
    field :twitch, default: "", type: :string, placeholder: "https://www.twitch.tv/yarotheslav"
    field :discord, default: "", type: :string, placeholder: "https://discord.gg/yarotheslav"
    field :telegram, default: "", type: :string, placeholder: "https://t.me/yarotheslav"
    field :whatsapp, default: "", type: :string, placeholder: "https://wa.me/yarotheslav"
  end

  def self.get_scope(scope_name)
    defined_fields
      .select { |field| field[:scope] == scope_name }
      .each_with_object({}) { |field, hash| hash[field[:key]] = send(field[:key]) }
  end
end
