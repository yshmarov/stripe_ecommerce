class SecuredController < ApplicationController
  before_action :authenticate

  USERNAME = ENV["ADMIN_USERNAME"].freeze
  PASSWORD = ENV["ADMIN_PASSWORD"].freeze

  private

  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == USERNAME && password == PASSWORD
    end
  end
end
