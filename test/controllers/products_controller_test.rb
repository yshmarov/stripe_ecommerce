require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  test "index" do
    get products_url
    assert_response :success

    product_drink = products(:monster_classic)
    product_food = products(:rafaello)

    assert_match product_drink.name, response.body
    assert_match product_food.name, response.body

    # filter by category
    get products_url(category: "food")
    assert_response :success
    assert_match product_food.name, response.body
    assert_no_match product_drink.name, response.body
  end

  test "search" do
    product_drink = products(:monster_classic)
    product_food = products(:rafaello)

    get products_url(query: "monster")
    assert_response :success
    assert_match product_drink.name, response.body
    assert_no_match product_food.name, response.body
  end

  test "show" do
    get product_url(products(:monster_classic))
    assert_response :success
  end
end
