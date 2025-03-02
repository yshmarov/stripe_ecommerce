module Admin
  class StatsController < SecuredController
    def index
      @most_popular_products = OrderItem.joins(:product).group("products.name").count
      @satisfaction = Order.group(:rating).count
      @income_per_day = Order.all.group_by_day(:created_at).sum(:total_amount)
    end
  end
end
