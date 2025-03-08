class StaticController < ApplicationController
  def terms_of_service
    render "static/index"
  end

  def privacy_policy
    render "static/index"
  end

  def refund_policy
    render "static/index"
  end

  def sitemap
    sitemap = @current_account.raw_sitemap
    respond_to do |format|
      format.xml { render html: sitemap }
    end
  end
end
