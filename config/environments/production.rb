Onemyday::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true

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
  config.action_mailer.default_url_options = {host: "onemyday.co"}

  # Defaults to Rails.root.join("public/assets")
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Prepend all log lines with the following tags
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # config.assets.precompile += %w( search.js )

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true
  I18n.default_locale = :en

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  # config.active_record.auto_explain_threshold_in_seconds = 0.5

  ENV["TWITTER_CONSUMER_KEY"] = "3Ot3E3BhpTFV5inPVXOw"
  ENV["TWITTER_CONSUMER_SECRET"] = "mNtee7A5W87WdMDlIBHCRQURv29ECTsKUlWoArY0A"

  ENV["FACEBOOK_APP_ID"] = "390488554357191"
  ENV["FACEBOOK_APP_SECRET"] = "b4ebceff89b8486225f5cb298a3da196"

  ENV["VKONTAKTE_API_KEY"] = "3486182"
  ENV["VKONTAKTE_API_SECRET"] = "dJLk9Y8Xh3jmF4Qqjowm"

  ENV["ONEMYDAY_API_KEY"] = "75c5e6875c4e6931943b88fe5941470b"

  ENV["HOST"] = "onemyday.co"

  PAPERCLIP_STORAGE_OPTS = {
      :storage        => :s3,
      :s3_credentials => "#{Rails.root}/config/s3.yml",
      :path           => ':attachment/:id/:style.:extension',
      :bucket         => 'onemyday'
  }

end
