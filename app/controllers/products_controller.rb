class ProductsController < ApplicationController
  include Pagy::Backend

  before_action :set_product, only: %i[show]

  def index
    @pagy, @products = pagy(@current_account.products.order(name: :asc))
  end

  def search
    @products = if params[:query].length > 2
                  @current_account.products.search(params[:query])
    else
                  @current_account.products.none
    end
  end

  def show; end

  private

  def set_product
    @product = @current_account.products.find(params[:id])
  end
end
