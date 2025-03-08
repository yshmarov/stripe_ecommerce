require "test_helper"

class AccountTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "generate_sitemap" do
    account = accounts(:one)
    account.generate_sitemap
    perform_enqueued_jobs
    assert_not_nil account.reload.raw_sitemap
  end
end
