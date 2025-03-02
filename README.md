# Minimal Stripe ecommerce store

Display non-recurring products index

### Customer-facing:

Core features:

- ✅ SEO-friendly product directory with search
- ✅ Add to cart
- ✅ Order summary
- ✅ Payment processing
- ✅ Order history
- ✅ No login flow (cookie = authentication)

Bonus features:

- ✅ i18n 🇬🇧🌍
- ✅ Order queue (private or public)
- ✅ Review (1 or 5 stars)
- ⏳ Log in with Google

### Admin:

- ✅ General store settings
- ✅ Order fulfillment
- ✅ Stats

## Usecases

- McDonalds-like self-service (restaurant)
- Online bookstore

### Deploy to production

ENV VARS

```sh
RAILS_MASTER_KEY
STRIPE_WEBHOOK_SECRET
STRIPE_SECRET_KEY
ADMIN_USERNAME
ADMIN_PASSWORD
```

Create a stripe webhook endpoint:

https://dashboard.stripe.com/webhooks/create?events=product.created%2Cproduct.deleted%2Cproduct.updated%2Cprice.created%2Cprice.deleted%2Cprice.updated%2Ccheckout.session.completed

[One-click Heroku deploy](https://dashboard.heroku.com/new?template=https://github.com/yshmarov/superails)
