class AiProductAnalyzer
  def initialize
    @client = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY"))
  end

  def is_book?(product)
    prompt = "Based on this product information, is this a book? Answer only 'yes' or 'no'.\n\n"
    prompt += "Product name: #{product.name}\n"
    prompt += "Product description: #{product.stripe_product["description"]}\n"

    response = @client.chat(
      parameters: {
        model: "gpt-3.5-turbo",
        messages: [ { role: "user", content: prompt } ],
        temperature: 0.7
      }
    )

    response.dig("choices", 0, "message", "content").downcase.strip == "yes"
  end
end
