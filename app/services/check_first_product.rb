class CheckFirstProduct
  def self.call
    first_product = Product.first
    return "No products found in the database." if first_product.nil?

    analyzer = AiProductAnalyzer.new
    is_book = analyzer.is_book?(first_product)

    "Product '#{first_product.name}': #{is_book ? 'is' : 'is not'} a book"
  end
end
