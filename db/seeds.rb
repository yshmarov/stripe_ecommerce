Product.create(name: 'Prince Polo', price: 199, category: 'food', image_url: 'https://i.imgur.com/l4tEqmL.png', description: 'Classic wafer bar covered in dark chocolate')
# Product.create(name: 'Donut Chocolate', price: 129, category: 'food', image_url: 'https://i.imgur.com/LRwEakM.png')
# Product.create(name: 'Donut limited', price: 159, category: 'food', image_url: 'https://i.imgur.com/3sgNWeJ.png')
# Product.create(name: 'Banana', price: 99, category: 'food', image_url: 'https://i.imgur.com/eUzrUjG.png')
# Product.create(name: 'Mullermilch CoCo', price: 499, category: 'drinks', image_url: 'https://i.imgur.com/OGLkpV5.png')
# Product.create(name: 'Mullermilch Chocolate', price: 499, category: 'drinks', image_url: 'https://i.imgur.com/fCHrRRT.png')
# Product.create(name: 'Mullermilch Strawberry', price: 499, category: 'drinks', image_url: 'https://i.imgur.com/0HICucM.png')
Product.create(name: 'Monster classic', price: 599, category: 'drinks', image_url: 'https://i.imgur.com/WEDXcDi.png', description: 'Original energy drink with a powerful blend of caffeine and B-vitamins')
Product.create(name: 'Monster juiced', price: 599, category: 'drinks', image_url: 'https://i.imgur.com/QNLaQ9L.png', description: 'Energizing blend with real fruit juice')
Product.create(name: 'Polaris Gazowana', price: 199, category: 'drinks', image_url: 'https://i.imgur.com/7BGt24V.png', description: 'Refreshing sparkling mineral water')
Product.create(name: 'Polaris Niegazowana', price: 159, category: 'drinks', image_url: 'https://i.imgur.com/CkaVyAQ.png', description: 'Pure still mineral water')
Product.create(name: 'Sezamki Classic', price: 399, category: 'food', image_url: 'https://i.imgur.com/r1pZQ1P.png', description: 'Traditional sesame seed candy bars')
Product.create(name: 'Rafaello', price: 99, category: 'food', image_url: 'https://i.imgur.com/XwLtkud.png', description: 'Coconut-almond confection in crispy white shell')
Product.create(name: 'Mini Bounty', price: 59, category: 'food', image_url: 'https://i.imgur.com/JasXScr.png', description: 'Mini chocolate bars with coconut filling')
Product.create(name: 'Mini Snickers', price: 59, category: 'food', image_url: 'https://i.imgur.com/ORYBJqE.png', description: 'Mini chocolate bars with peanuts, caramel and nougat')

# Product.all.each do |product|
#   stripe_product = Stripe::Product.create(name: product.name, images: [ product.image_url ], metadata: { product_id: product.id }, description: product.description)
#   stripe_price = Stripe::Price.create(
#     product: stripe_product.id,
#     unit_amount: product.price,
#     currency: Setting.currency
#   )
# end
