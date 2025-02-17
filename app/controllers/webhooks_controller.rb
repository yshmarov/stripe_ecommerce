class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    payload = request.body.read
    sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
    endpoint_secret = ENV.fetch("STRIPE_WEBHOOK_SECRET")
    event = nil

    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, endpoint_secret
      )
    rescue JSON::ParserError => e
      status 400
      return
    rescue Stripe::SignatureVerificationError => e
      status 400
      return
    end

    case event.type
    when "checkout.session.completed"
      session = event.data.object
      order = Order.find(session.client_reference_id)
      order.submitted! if order.draft?
      # when "payment_intent.succeeded"
      #   payment_intent = event.data.object
      #   order = Order.find(payment_intent.client_reference_id)
      #   order.paid!
    end

    render json: { status: "success" }
  end
end
