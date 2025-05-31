require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  test "index" do
    product_drink = products(:monster_classic)
    product_food = products(:rafaello)

    get products_url
    assert_response :success


    assert_match product_drink.name, response.body
    assert_match product_food.name, response.body
  end

  test "search" do
    get search_products_path, params: { query: "monster" }
    assert_response :success
    assert_match "Monster", response.body
    assert_no_match "Rafaello", response.body
  end

  test "show" do
    get product_url(products(:monster_classic).id)
    assert_response :success
  end
end
