# config/initializers/good_job.rb
GoodJob::Engine.middleware.use(Rack::Auth::Basic) do |username, password|
  ActiveSupport::SecurityUtils.secure_compare(ENV["ADMIN_USERNAME"], username) &
    ActiveSupport::SecurityUtils.secure_compare(ENV["ADMIN_PASSWORD"], password)
end
