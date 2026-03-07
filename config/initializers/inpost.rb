# InPost API Configuration
Rails.application.config.inpost = {
  api_url: ENV.fetch('INPOST_API_URL', 'https://api.inpost.pl'),
  api_key: ENV.fetch('INPOST_API_KEY', nil),
  timeout: 30,
  pickup_point_cache_duration: 1.hour
}

# Validate configuration in production
if Rails.env.production? && Rails.application.config.inpost[:api_key].blank?
  Rails.logger.warn "INPOST_API_KEY is not configured. InPost integration will not work."
end
