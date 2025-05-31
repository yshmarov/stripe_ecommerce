module Admin
  class StatsController < SecuredController
    def index
      @most_popular_products = OrderItem
        .joins("INNER JOIN orders ON orders.id = order_items.order_id")
        .joins("INNER JOIN prices ON prices.id = order_items.price_id")
        .joins("INNER JOIN products ON products.id = prices.product_id")
        .where.not(orders: { status: "draft" })
        .group("products.name")
        .count
      @satisfaction = Order.where.not(status: "draft").group(:rating).count
    end
  end
end
