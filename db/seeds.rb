OrderItem.destroy_all
Order.destroy_all
Price.destroy_all
Product.destroy_all
Account.destroy_all
Setting.destroy_all

currency = "pln"

product_objects = [
  { name: 'Prince Polo',
    price: 199,
    image_url: 'https://i.imgur.com/l4tEqmL.png',
    description: 'Classic wafer bar covered in dark chocolate',
    metadata: { foo: "bar", bizz: "bazz" },
    marketing_features: [ 'gluten-free', 'dairy-free', 'vegan', 'organic' ] },
  { name: 'Donut Chocolate', price: 129, image_url: 'https://i.imgur.com/LRwEakM.png' },
  { name: 'Donut limited', price: 159, image_url: 'https://i.imgur.com/3sgNWeJ.png' },
  { name: 'Banana', price: 99, image_url: 'https://i.imgur.com/eUzrUjG.png' },
  { name: 'Mullermilch CoCo', price: 499, image_url: 'https://i.imgur.com/OGLkpV5.png' },
  { name: 'Mullermilch Chocolate', price: 499, image_url: 'https://i.imgur.com/fCHrRRT.png' },
  { name: 'Mullermilch Strawberry', price: 499, image_url: 'https://i.imgur.com/0HICucM.png' },
  { name: 'Monster classic', price: 599, image_url: 'https://i.imgur.com/WEDXcDi.png', description: 'Original energy drink with a powerful blend of caffeine and B-vitamins' },
  { name: 'Monster juiced', price: 599, image_url: 'https://i.imgur.com/QNLaQ9L.png', description: 'Energizing blend with real fruit juice' },
  { name: 'Polaris Gazowana', price: 199, image_url: 'https://i.imgur.com/7BGt24V.png', description: 'Refreshing sparkling mineral water' },
  { name: 'Polaris Niegazowana', price: 159, image_url: 'https://i.imgur.com/CkaVyAQ.png', description: 'Pure still mineral water' },
  { name: 'Sezamki Classic', price: 399, image_url: 'https://i.imgur.com/r1pZQ1P.png', description: 'Traditional sesame seed candy bars' },
  { name: 'Rafaello', price: 99, image_url: 'https://i.imgur.com/XwLtkud.png', description: 'Coconut-almond confection in crispy white shell' },
  { name: 'Mini Bounty', price: 59, image_url: 'https://i.imgur.com/JasXScr.png', description: 'Mini chocolate bars with coconut filling' },
  { name: 'Mini Snickers', price: 59, image_url: 'https://i.imgur.com/ORYBJqE.png', description: 'Mini chocolate bars with peanuts, caramel and nougat' }
]

stripe_account = Stripe::Account.retrieve
Account.create!(stripe_account_id: stripe_account.id, stripe_account:)

if Stripe::Product.list.empty?
  product_objects.each do |product_object|
    stripe_product = Stripe::Product.create(name: product_object[:name], images: [ product_object[:image_url] ], description: product_object[:description])
    stripe_price = Stripe::Price.create(product: stripe_product.id, unit_amount: product_object[:price], currency:)
    stripe_product.default_price = stripe_price.id
    stripe_product.save
  end
end

Stripe::SyncProductsJob.perform_now

if Stripe::ShippingRate.list.empty?
  Stripe::ShippingRate.create(
    display_name: "Standard International Shipping",
    type: "fixed_amount",
    fixed_amount: {
      amount: 1000,
      currency:
    },
    delivery_estimate: {
      minimum: {
        unit: "business_day",
        value: 7
      },
      maximum: {
        unit: "business_day",
        value: 10
      }
    }
  )

  Stripe::ShippingRate.create(
    display_name: "Takeaway",
    type: "fixed_amount",
    fixed_amount: {
      amount: 0,
      currency:
    },
    delivery_estimate: {
      minimum: {
        unit: "business_day",
        value: 1
      },
      maximum: {
        unit: "business_day",
        value: 1
      }
    }
  )
end

puts "🌱 Database seeded"
puts "Sellable stripe products: #{Product.count}"
puts "Sellable stripe prices: #{Price.count}"
puts "Shipping Rates: #{Stripe::ShippingRate.list.count}"
