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
end
