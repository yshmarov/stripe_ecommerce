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
end
