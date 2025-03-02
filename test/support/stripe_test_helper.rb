module StripeTestHelper
  def mock_stripe_account
    stripe_account = OpenStruct.new(
      settings: OpenStruct.new(
        dashboard: OpenStruct.new(
          display_name: "Warsaw Books Sp. z o.o."
        ),
        branding: OpenStruct.new(
          primary_color: "#000000",
          secondary_color: "#000000",
          logo: "file_123" # mock logo ID
        ),
        business_profile: OpenStruct.new(
          support_phone: "+48 123 456 789"
        )
      )
    )

    stripe_file = OpenStruct.new(
      links: [
        OpenStruct.new(url: "https://superails.com/logo.png")
      ]
    )

    # Mock Stripe::Account.retrieve
    Stripe::Account.stubs(:retrieve).returns(stripe_account)

    # Mock Stripe::File.retrieve
    Stripe::File.stubs(:retrieve).with("file_123").returns(stripe_file)

    stripe_account
  end
end
