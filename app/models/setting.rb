# RailsSettings Model
class Setting < RailsSettings::Base
  cache_prefix { "v1" }

  scope :business do
    field :app_name, default: "Snack Bar by Yaro", type: :string, validates: { presence: true, length: { in: 2..20 } }
    field :logo_url, type: :string, default: "https://superails.com/logo.png"
    field :description, default: "Self checkout snack bar", type: :text, validates: { presence: true, length: { in: 2..200 } }
    field :address, default: "ul. Kowalska 123, 00-000 Warszawa", type: :string, validates: { presence: true, length: { in: 2..200 } }
    field :email, default: "info@snackbarbyyaro.com", type: :string, validates: { presence: true, length: { in: 2..100 } }
    field :phone, default: "+48 123 456 789", type: :string, validates: { presence: true, length: { in: 2..20 } }
    field :trade_name, default: "Snack Bar By Yaro LLC", type: :string, validates: { presence: true, length: { in: 2..40 } }
    field :trade_vat_number, default: "PL1234567890", type: :string, validates: { presence: true, length: { in: 2..20 } }

    field :socials, type: :hash, default: {
      instagram: "https://www.instagram.com/yaro_the_slav",
      twitter: "https://twitter.com/yarotheslav",
      tiktok: "",
      linkedin: "",
      youtube: "",
      facebook: "",
      pinterest: "",
      twitch: "",
      discord: "",
      telegram: "",
      whatsapp: ""
    }
  end

  scope :payments do
    field :currency, default: "USD", type: :string
  end

  scope :application do
    field :public_order_queue, default: true, type: :boolean
  end
end
