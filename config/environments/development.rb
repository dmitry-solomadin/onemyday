Onemyday::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  config.action_mailer.raise_delivery_errors = true

  # Change mail delvery to either :smtp, :sendmail, :file, :test
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
      address: "smtp.gmail.com",
      port: 587,
      domain: "gmail.com",
      authentication: "plain",
      enable_starttls_auto: true,
      user_name: "onemyday.co@gmail.com",
      password: "thequaker"
  }

  # Specify what domain to use for mailer URLs
  config.action_mailer.default_url_options = {host: "localhost:3000"}

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  config.active_record.auto_explain_threshold_in_seconds = 0.5

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  ENV["TWITTER_CONSUMER_KEY"] = "3Ot3E3BhpTFV5inPVXOw"
  ENV["TWITTER_CONSUMER_SECRET"] = "mNtee7A5W87WdMDlIBHCRQURv29ECTsKUlWoArY0A"

  ENV["FACEBOOK_APP_ID"] = "272763286172620"
  ENV["FACEBOOK_APP_SECRET"] = "e347de77c945e9a8ea95e9548e8a9a31"

  ENV["VKONTAKTE_API_KEY"] = "3486198"
  ENV["VKONTAKTE_API_SECRET"] = "qthRv5xv3SNvo8ANh41r"

  ENV["ONEMYDAY_API_KEY"] = "75c5e6875c4e6931943b88fe5941470b"

  ENV["HOST"] = "localhost:3000"

  I18n.default_locale = :en

  PAPERCLIP_STORAGE_OPTS = {}

  config.log_level = :debug
end
