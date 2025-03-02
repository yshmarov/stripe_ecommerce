module ApplicationHelper
  def meta_tags(title: nil, description: nil, image: nil)
    # Set the page title
    content_for(:title) { title } if title

    content_for :head do
      tags = []

      # Basic meta tags
      tags << tag(:meta, name: "title", content: title) if title
      tags << tag(:meta, name: "description", content: description) if description

      # Open Graph meta tags
      tags << tag(:meta, property: "og:title", content: title) if title
      tags << tag(:meta, property: "og:description", content: description) if description
      tags << tag(:meta, property: "og:image", content: image) if image
      tags << tag(:meta, property: "og:type", content: "website")

      # Twitter Card meta tags
      tags << tag(:meta, name: "twitter:card", content: "summary_large_image")
      tags << tag(:meta, name: "twitter:title", content: title) if title
      tags << tag(:meta, name: "twitter:description", content: description) if description
      tags << tag(:meta, name: "twitter:image", content: image) if image

      tags.join("\n").html_safe
    end
  end

  def flag(locale)
    case locale
    when :en then "🇬🇧"
    when :pl then "🇵🇱"
    when :ua then "🇺🇦"
    end
  end

  def currency_code_to_symbol(code)
    case code
    when "usd" then "$"
    when "eur" then "€"
    when "gbp" then "£"
    when "uah" then "₴"
    when "pln" then "zł"
    end
  end

  def markdown(text)
    return "" if text.blank?

    renderer = Redcarpet::Render::HTML.new(
      hard_wrap: true,
      filter_html: true,
      link_attributes: { target: "_blank", rel: "noopener noreferrer" }
    )

    markdown = Redcarpet::Markdown.new(
      renderer,
      autolink: true,
      no_intra_emphasis: true,
      fenced_code_blocks: true,
      lax_spacing: true,
      strikethrough: true,
      superscript: true,
      tables: true
    )

    markdown.render(text).html_safe
  end
end
