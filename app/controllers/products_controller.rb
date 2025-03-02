class ProductsController < ApplicationController
  before_action :set_product, only: %i[show]

  def index
    @products = Product.order(name: :asc)
  end

  def search
    @products = if params[:query].length > 2
                  Product.search(params[:query])
    else
                  Product.none
    end
  end

  def show; end

  private

  def set_product
    @product = Product.find(params[:id])
  end
end
