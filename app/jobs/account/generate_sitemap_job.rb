class Account::GenerateSitemapJob < ApplicationJob
  queue_as :default

  def perform(account)
    xml = generate_sitemap(account)
    account.update_column(:raw_sitemap, xml)
  end

  def generate_sitemap(account)
    xml = ::Builder::XmlMarkup.new(indent: 2)
    xml.instruct!

    xml.urlset(
      "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9",
      "xmlns:image" => "http://www.google.com/schemas/sitemap-image/1.1"
    ) do
      # Add homepage

      # Add products index
      xml.url do
        xml.loc("#{base_url}/shop")
        xml.changefreq("daily")
        xml.priority(0.9)
        xml.lastmod(Time.current.iso8601)
      end

      # Add individual products
      account.products.find_each do |product|
        xml.url do
          xml.loc("#{base_url}/shop/#{product.slug || product.id}")
          xml.changefreq("daily")
          xml.priority(0.8)
          xml.lastmod(product.updated_at.iso8601)

          # Add product images if present
          if product.image_url.present?
            xml.tag!("image:image") do
              xml.tag!("image:loc", product.image_url)
              xml.tag!("image:title", product.name)
            end
          end
        end
      end

      # Add static pages
      [ "terms_of_service", "privacy_policy", "refund_policy" ].each do |page|
        xml.url do
          xml.loc("#{base_url}/#{page}")
          xml.changefreq("monthly")
          xml.priority(0.3)
          xml.lastmod(Time.current.iso8601)
        end
      end
    end

    xml.target!
  end

  private

  def base_url
    if Rails.env.production?
      "https://#{ENV['HOST_NAME']}"
    else
      "http://localhost:3000"
    end
  end
end
