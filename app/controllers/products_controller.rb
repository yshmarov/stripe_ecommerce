class ProductsController < ApplicationController
  before_action :set_product, only: %i[show]

  def index
    @products = if params[:query].present?
                  Product.order(name: :asc).search(params[:query])
    else
                  Product.order(name: :asc)
    end
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
