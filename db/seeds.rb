product_objects = [
  { name: 'Prince Polo', price: 199, category: 'food', image_url: 'https://i.imgur.com/l4tEqmL.png', description: 'Classic wafer bar covered in dark chocolate' },
  { name: 'Donut Chocolate', price: 129, category: 'food', image_url: 'https://i.imgur.com/LRwEakM.png' },
  { name: 'Donut limited', price: 159, category: 'food', image_url: 'https://i.imgur.com/3sgNWeJ.png' },
  { name: 'Banana', price: 99, category: 'food', image_url: 'https://i.imgur.com/eUzrUjG.png' },
  { name: 'Mullermilch CoCo', price: 499, category: 'drinks', image_url: 'https://i.imgur.com/OGLkpV5.png' },
  { name: 'Mullermilch Chocolate', price: 499, category: 'drinks', image_url: 'https://i.imgur.com/fCHrRRT.png' },
  { name: 'Mullermilch Strawberry', price: 499, category: 'drinks', image_url: 'https://i.imgur.com/0HICucM.png' },
  { name: 'Monster classic', price: 599, category: 'drinks', image_url: 'https://i.imgur.com/WEDXcDi.png', description: 'Original energy drink with a powerful blend of caffeine and B-vitamins' },
  { name: 'Monster juiced', price: 599, category: 'drinks', image_url: 'https://i.imgur.com/QNLaQ9L.png', description: 'Energizing blend with real fruit juice' },
  { name: 'Polaris Gazowana', price: 199, category: 'drinks', image_url: 'https://i.imgur.com/7BGt24V.png', description: 'Refreshing sparkling mineral water' },
  { name: 'Polaris Niegazowana', price: 159, category: 'drinks', image_url: 'https://i.imgur.com/CkaVyAQ.png', description: 'Pure still mineral water' },
  { name: 'Sezamki Classic', price: 399, category: 'food', image_url: 'https://i.imgur.com/r1pZQ1P.png', description: 'Traditional sesame seed candy bars' },
  { name: 'Rafaello', price: 99, category: 'food', image_url: 'https://i.imgur.com/XwLtkud.png', description: 'Coconut-almond confection in crispy white shell' },
  { name: 'Mini Bounty', price: 59, category: 'food', image_url: 'https://i.imgur.com/JasXScr.png', description: 'Mini chocolate bars with coconut filling' },
  { name: 'Mini Snickers', price: 59, category: 'food', image_url: 'https://i.imgur.com/ORYBJqE.png', description: 'Mini chocolate bars with peanuts, caramel and nougat' }
]

product_objects.each do |product_object|
  stripe_product = Stripe::Product.create(name: product_object[:name], images: [ product_object[:image_url] ], description: product_object[:description])
  stripe_price = Stripe::Price.create(product: stripe_product.id, unit_amount: product_object[:price], currency: Setting.currency)
  product = Product.find_or_initialize_by(product_object)
  product.stripe_price_id = stripe_price.id
  product.save!
end
