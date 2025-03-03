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
STRIPE_SECRET_KEY
STRIPE_WEBHOOK_SECRET
ADMIN_USERNAME
ADMIN_PASSWORD
HONEYBADGER_API_KEY
```

Push your keys to Heroku:

```sh
heroku config:set RAILS_MASTER_KEY=`cat config/master.key`
heroku config:set STRIPE_WEBHOOK_SECRET='whsec_foo'
heroku config:set STRIPE_SECRET_KEY='sk_foo'
heroku config:set ADMIN_USERNAME='admin'
heroku config:set ADMIN_PASSWORD='password'
heroku config:set HONEYBADGER_API_KEY='hbp_foo'
```

[Create a stripe webhook endpoint](https://dashboard.stripe.com/webhooks/create?events=product.created%2Cproduct.deleted%2Cproduct.updated%2Cprice.created%2Cprice.deleted%2Cprice.updated%2Ccheckout.session.completed)

[One-click Heroku deploy](https://dashboard.heroku.com/new?template=https://github.com/yshmarov/superails)
