module Admin
  class OrdersController < SecuredController
    before_action :set_order, only: %i[show update]

    def index
      @orders = Order.queued.order(created_at: :desc).includes(:order_items)
    end

    def show; end

    def update
      if @order.update(status: @order.next_status)
        redirect_back fallback_location: [ :admin, @order ], notice: "Status updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_order
      @order = Order.find(params[:id])
    end
  end
end
