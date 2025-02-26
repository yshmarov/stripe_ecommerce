class StaticController < ApplicationController
  def terms_of_service
    render plain: Setting.terms_of_service
  end

  def privacy_policy
    render plain: Setting.privacy_policy
  end

  def refund_policy
    render plain: Setting.refund_policy
  end
end
